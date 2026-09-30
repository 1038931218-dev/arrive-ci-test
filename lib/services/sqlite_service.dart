import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../config/constants.dart';
import '../models/location.dart';
import '../models/fence_state.dart';

class SqliteService {
  SqliteService._();
  static final SqliteService instance = SqliteService._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasePath();
    _db = await openDatabase(
      dbPath,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
    return _db!;
  }

  Future<String> getDatabasePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, AppConstants.dbName);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE locations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        radius REAL NOT NULL DEFAULT 50,
        repeat_minutes INTEGER NOT NULL DEFAULT 0,
        enabled INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER,
        updated_at INTEGER,
        note TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE fence_state (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        location_id INTEGER NOT NULL,
        entered_at INTEGER,
        last_remind_at INTEGER,
        is_inside INTEGER NOT NULL DEFAULT 0,
        current_broadcast INTEGER,
        updated_at INTEGER,
        FOREIGN KEY(location_id) REFERENCES locations(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE UNIQUE INDEX idx_fence_location ON fence_state(location_id)');
  }

  // ---- Location CRUD ----
  Future<int> insertLocation(Location loc) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = loc.toMap();
    map.remove('id');
    map['created_at'] = now;
    map['updated_at'] = now;
    return db.insert('locations', map);
  }

  Future<int> updateLocation(Location loc) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = loc.toMap();
    map.remove('id');
    map['updated_at'] = now;
    return db.update('locations', map, where: 'id = ?', whereArgs: [loc.id]);
  }

  Future<int> deleteLocation(int id) async {
    final db = await database;
    return db.delete('locations', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Location>> getAllLocations() async {
    final db = await database;
    final rows = await db.query('locations', orderBy: 'id DESC');
    return rows.map((e) => Location.fromMap(e)).toList();
  }

  Future<List<Location>> getEnabledLocations() async {
    final db = await database;
    final rows = await db.query('locations', where: 'enabled = 1', orderBy: 'id DESC');
    return rows.map((e) => Location.fromMap(e)).toList();
  }

  Future<Location?> getLocation(int id) async {
    final db = await database;
    final rows = await db.query('locations', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return Location.fromMap(rows.first);
  }

  // ---- Fence State ----
  Future<FenceState?> getFenceState(int locationId) async {
    final db = await database;
    final rows = await db.query('fence_state',
        where: 'location_id = ?', whereArgs: [locationId], limit: 1);
    if (rows.isEmpty) return null;
    return FenceState.fromMap(rows.first);
  }

  Future<int> upsertFenceState(FenceState state) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = state.toMap();
    map.remove('id');
    map['updated_at'] = now;
    return db.insert('fence_state', map,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<FenceState>> getAllFenceStates() async {
    final db = await database;
    final rows = await db.query('fence_state');
    return rows.map((e) => FenceState.fromMap(e)).toList();
  }

  Future<void> clearFenceState(int locationId) async {
    final db = await database;
    await db.delete('fence_state',
        where: 'location_id = ?', whereArgs: [locationId]);
  }
}
