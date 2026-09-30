import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../config/constants.dart';

/// Thin wrapper around flutter_local_notifications.
/// P0 only needs a plain (non-AI, non-voice) notification for geofence events.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _inited = false;

  Future<void> init() async {
    if (_inited) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings =
        InitializationSettings(android: androidSettings);

    await _plugin.initialize(initializationSettings);

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    // Android 13+ requires a runtime permission for notifications.
    await android?.requestNotificationsPermission();

    const channel = AndroidNotificationChannel(
      AppConstants.channelId,
      AppConstants.channelName,
      description: AppConstants.channelDesc,
      importance: Importance.high,
    );
    await android?.createNotificationChannel(channel);

    _inited = true;
  }

  Future<void> showGeofenceReminder({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      AppConstants.channelId,
      AppConstants.channelName,
      channelDescription: AppConstants.channelDesc,
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      AppConstants.geofenceNotifIdBase + id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(AppConstants.geofenceNotifIdBase + id);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
