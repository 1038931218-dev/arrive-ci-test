import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/location.dart';
import '../services/sqlite_service.dart';

class LocationListNotifier extends AsyncNotifier<List<Location>>{
  @override
  Future<List<Location>> build() async {
    return SqliteService.instance.getAllLocations();
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> add(Location loc) async {
    await SqliteService.instance.insertLocation(loc);
    await reload();
  }

  Future<void> update(Location loc) async {
    await SqliteService.instance.updateLocation(loc);
    await reload();
  }

  Future<void> remove(int id) async {
    await SqliteService.instance.deleteLocation(id);
    await reload();
  }
}


final locationListProvider =
    AsyncNotifierProvider<LocationListNotifier, List<Location>>(
    LocationListNotifier.new);
