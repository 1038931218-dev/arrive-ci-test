import 'dart:async';

import '../config/constants.dart';
import '../models/fence_state.dart';
import '../models/location.dart';
import '../utils/distance_utils.dart';
import 'notification_service.dart';
import 'sqlite_service.dart';

/// Result of evaluating all geofences against a location fix.
class GeofenceEvaluation {
  final int? activeLocationId;
  final double? activeDistance;
  final bool changed;
  const GeofenceEvaluation({
    this.activeLocationId,
    this.activeDistance,
    this.changed = false,
  });
}

class GeofenceService {
  GeofenceService._();
  static final GeofenceService instance = GeofenceService._();

  final SqliteService _db = SqliteService.instance;
  final NotificationService _notif = NotificationService.instance;

  /// Evaluate all enabled fences for the current fix and decide the nearest
  /// active fence. Applies enter/leave hysteresis and repeat frequency.
  Future<GeofenceEvaluation> evaluate({
    required double lat,
    required double lng,
  }) async {
    final locations = await _db.getEnabledLocations();

    // 1. Find all fences whose distance < radius (candidates)
    final inside = <Map<String, dynamic>>[];
    for (var loc in locations) {
      final d = DistanceUtils.distanceMeters(lat, lng, loc.latitude, loc.longitude);
      if (d < loc.radius) {
        inside.add({'loc': loc, 'dist': d});
      }
    }

    // 2. Sort by distance ascending (nearest first)
    inside.sort((a, b) =>
        (a['dist'] as double).compareTo(b['dist'] as double));

    // 3. Determine the current broadcast fence from persisted state
    int? currentBroadcastId;
    for (var loc in locations) {
      final st = await _db.getFenceState(loc.id!);
      if (st != null && st.currentBroadcast != null && st.isInside) {
        currentBroadcastId = st.currentBroadcast;
        break;
      }
    }

    // 4. Choose the nearest candidate (considering switch hysteresis)
    int? targetId;
    double? targetDist;
    if (inside.isNotEmpty) {
      final nearest = inside.first;
      targetId = (nearest['loc'] as Location).id;
      targetDist = nearest['dist'] as double;

      if (currentBroadcastId != null && currentBroadcastId != targetId) {
        // Only switch if the new one is at least switchMinDelta nearer than
        // the currently broadcast fence (avoid flickering).
        final cur = await _db.getLocation(currentBroadcastId);
        if (cur != null) {
          final curDist = DistanceUtils.distanceMeters(
            lat, lng, cur.latitude, cur.longitude);
          if (curDist - targetDist < AppConstants.switchMinDelta) {
            targetId = currentBroadcastId;
            targetDist = curDist;
          }
        }
      }
    }

    // 5. Persist fence state changes and trigger reminders
    bool changed = false;
    final now = DateTime.now().millisecondsSinceEpoch;
    for (var loc in locations) {
      final d = DistanceUtils.distanceMeters(lat, lng, loc.latitude, loc.longitude);
      var state = await _db.getFenceState(loc.id!) ??
          FenceState(locationId: loc.id!);
      final wasInside = state.isInside;

      // Enter condition: distance < radius
      // Leave condition: distance > radius + exitBuffer (hysteresis)
      if (!wasInside && d < loc.radius) {
        // Entered the fence
        state = state.copyWith(
          isInside: true,
          enteredAt: now,
          updatedAt: now,
        );
        await _db.upsertFenceState(state);
        changed = true;
      } else if (wasInside && d > loc.radius + AppConstants.exitBuffer) {
        // Left the fence
        await _db.upsertFenceState(
          state.copyWith(
            isInside: false,
            currentBroadcast: null,
            updatedAt: now,
          ),
        );
        await _notif.cancel(loc.id!);
        changed = true;
      }
    }

    // Broadcast for the target fence
    if (targetId != null) {
      final target = await _db.getLocation(targetId);
      if (target != null) {
        final state = await _db.getFenceState(targetId) ??
            FenceState(locationId: targetId, isInside: true);
        final last = state.lastRemindAt;
        final intervalMs = target.repeatMinutes * 60 * 1000;
        final due = last == null ||
            intervalMs == 0 ||
            (now - last) >= intervalMs;
        if (due) {
          await _notif.showGeofenceReminder(
            id: targetId,
            title: 'Arrived: ${target.name}',
            body: target.note ?? 'You have tasks at this location.',
          );
          await _db.upsertFenceState(
            state.copyWith(
              isInside: true,
              currentBroadcast: targetId,
              lastRemindAt: now,
              updatedAt: now,
            ),
          );
        }
      }
    }

    return GeofenceEvaluation(
      activeLocationId: targetId,
      activeDistance: targetDist,
      changed: changed,
    );
  }

  /// Reset all fence state (e.g. on app restart if desired).
  Future<void> resetAll() async {
    final states = await _db.getAllFenceStates();
    for (var s in states) {
      await _db.clearFenceState(s.locationId);
    }
  }
}
