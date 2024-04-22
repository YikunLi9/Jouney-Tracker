import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('locations.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const doubleType = 'REAL NOT NULL';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE locations (
  id $idType,
  latitude $doubleType,
  longitude $doubleType,
  timestamp $textType
)
''');
  }

  Future<void> insertLocation(double latitude, double longitude) async {
    final db = await instance.database;
    final json = {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await db.insert('locations', json);
  }

  Future<List<LatLng>> getTodayLocations() async {
    final db = await database;
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    List<Map<String, dynamic>> result = await db.query(
        'locations',
        where: "timestamp LIKE ?",
        whereArgs: ["$today%"]
    );

    List<LatLng> points = result.map((record) {
      return LatLng(record['latitude'], record['longitude']);
    }).toList();

    return points;
  }

  Future<List<LatLng>> getLocationsByDate(DateTime date) async {
    final db = await database;
    String dateStr = DateFormat('yyyy-MM-dd').format(date);
    List<Map<String, dynamic>> result = await db.query(
        'locations',
        where: "strftime('%Y-%m-%d', timestamp) = ?",
        whereArgs: [dateStr]
    );

    List<LatLng> points = result.map((map) => LatLng(map['latitude'], map['longitude'])).toList();
    return points;
  }

  Future<List<Map<String, dynamic>>> getAllLocations() async {
    final db = await database;
    final result = await db.query('locations');
    return result;
  }

  Future<int> deleteAllLocations() async {
    final db = await database;
    final result = await db.delete('locations'); // Deletes all rows in locations table
    return result;
  }

}
