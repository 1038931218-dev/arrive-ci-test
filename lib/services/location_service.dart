import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  Future<bool> ensurePermission() async {
    final check = await Permission.locationWhenInUse.request();
    if (check == PermissionStatus.granted) return true;
    final always = await Permission.locationAlways.request();
    return always == PermissionStatus.granted;
  }

  Future<Position?> getCurrentPosition() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return null;
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
    } catch (_) {
      return null;
    }
  }

  Stream<Position> positionStream() {
    return Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
  }

  // One-shot high-accuracy read for foreground loop
  Future<Position?> getHighAccuracyPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (_) {
      return null;
    }
  }
}
