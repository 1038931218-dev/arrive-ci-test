class AppConstants {
  AppConstants._();

  static const String appName = 'Arrive';
  static const String dbName = 'arrive.db';
  static const int dbVersion = 1;

  // Geofence defaults
  static const double defaultRadius = 50.0;
  // Exit threshold buffer to avoid flickering (radius + buffer)
  static const double exitBuffer = 50.0;
  // Min distance gain (meters) required before switching nearest broadcast
  static const double switchMinDelta = 30.0;
  // Location update interval in seconds
  static const int locationIntervalSec = 15;

  // Notification channel
  static const String channelId = 'arrive_geofence';
  static const String channelName = 'Location reminders';
  static const String channelDesc = 'Reminders when you arrive at a saved place';
  static const int foregroundNotifId = 1;
  static const int geofenceNotifIdBase = 1000;
}
