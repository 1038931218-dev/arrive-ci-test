import 'dart:async';

import '../config/constants.dart';
import 'geofence_service.dart';
import 'location_service.dart';

/// Owns the polling loop that feeds GPS fixes into [GeofenceService].
///
/// P0 uses a simple periodic timer instead of a native geofencing plugin so we
/// do not depend on any paid/closed-source component. The loop is intentionally
/// idempotent: calling [start] twice is a no-op, and [stop] always cancels the
/// timer.
class GeofenceMonitorService {
  GeofenceMonitorService._();
  static final GeofenceMonitorService instance = GeofenceMonitorService._();

  final LocationService _location = LocationService.instance;
  final GeofenceService _geofence = GeofenceService.instance;

  Timer? _timer;
  bool _busy = false;

  bool get isRunning => _timer != null;

  /// Starts the polling loop. Safe to call multiple times.
  Future<bool> start() async {
    if (_timer != null) return true;

    final ok = await _location.ensurePermission();
    if (!ok) return false;

    _timer = Timer.periodic(
      const Duration(seconds: AppConstants.locationIntervalSec),
      (_) => _tick(),
    );
    // Fire one immediate fix so the user gets feedback without waiting.
    unawaited(_tick());
    return true;
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _tick() async {
    if (_busy) return;
    _busy = true;
    try {
      final pos = await _location.getHighAccuracyPosition();
      if (pos == null) return;
      await _geofence.evaluate(lat: pos.latitude, lng: pos.longitude);
    } catch (_) {
      // Swallow errors: a bad fix must not kill the loop.
    } finally {
      _busy = false;
    }
  }
}
