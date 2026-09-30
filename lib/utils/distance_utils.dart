import 'dart:math' as math;

class DistanceUtils {
  DistanceUtils._();

  static const double earthRadiusMeters = 6371000.0;

  // Haversine distance in meters
  static double distanceMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = (lat2 - lat1) * math.pi / 180.0;
    final dLon = (lon2 - lon1) * math.pi / 180.0;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180.0) *
            math.cos(lat2 * math.pi / 180.0) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  static String formatMeters(double m) {
    if (m < 1000) {
      return '${m.round()} m';
    }
    return '${(m / 1000).toStringAsFixed(2)} km';
  }
}
