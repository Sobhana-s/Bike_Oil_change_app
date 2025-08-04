import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/odometer_reading.dart';
import '../models/user.dart';

class DatabaseService {
  static Database? _database;

  // Get the database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'bike_oil_change.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Create database tables
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE odometer_readings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bikeNumber TEXT NOT NULL,
        readingKm INTEGER NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE oil_changes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bikeNumber TEXT NOT NULL,
        odometerKm INTEGER NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  // Insert a new odometer reading
  Future<int> insertOdometerReading(OdometerReading reading) async {
    final db = await database;
    return await db.insert('odometer_readings', {
      'bikeNumber': reading.bikeNumber,
      'readingKm': reading.readingKm,
      'date': reading.date.toIso8601String(),
    });
  }

  // Get all odometer readings for a specific bike
  Future<List<OdometerReading>> getOdometerReadings(String bikeNumber) async {
    final db = await database;
    final results = await db.query(
      'odometer_readings',
      where: 'bikeNumber = ?',
      whereArgs: [bikeNumber],
      orderBy: 'date DESC',
    );

    return results.map((map) => OdometerReading.fromJson({
      'id': map['id'] as int,
      'bikeNumber': map['bikeNumber'] as String,
      'readingKm': map['readingKm'] as int,
      'date': map['date'] as String,
    })).toList();
  }

  // Get the latest odometer reading
  Future<OdometerReading?> getLatestReading(String bikeNumber) async {
    final db = await database;
    final results = await db.query(
      'odometer_readings',
      where: 'bikeNumber = ?',
      whereArgs: [bikeNumber],
      orderBy: 'date DESC',
      limit: 1,
    );

    if (results.isEmpty) return null;

    return OdometerReading.fromJson({
      'id': results.first['id'] as int,
      'bikeNumber': results.first['bikeNumber'] as String,
      'readingKm': results.first['readingKm'] as int,
      'date': results.first['date'] as String,
    });
  }

  // Record an oil change
  Future<int> recordOilChange(String bikeNumber, int odometerKm) async {
    final db = await database;
    return await db.insert('oil_changes', {
      'bikeNumber': bikeNumber,
      'odometerKm': odometerKm,
      'date': DateTime.now().toIso8601String(),
    });
  }

  // Get the latest oil change
  Future<Map<String, dynamic>?> getLatestOilChange(String bikeNumber) async {
    final db = await database;
    final results = await db.query(
      'oil_changes',
      where: 'bikeNumber = ?',
      whereArgs: [bikeNumber],
      orderBy: 'date DESC',
      limit: 1,
    );

    if (results.isEmpty) return null;
    return results.first;
  }

  // Calculate distance since last oil change
  Future<int> getDistanceSinceLastOilChange(String bikeNumber) async {
    final latestReading = await getLatestReading(bikeNumber);
    final latestOilChange = await getLatestOilChange(bikeNumber);

    if (latestReading == null) return 0;
    if (latestOilChange == null) return latestReading.readingKm;

    return latestReading.readingKm - (latestOilChange['odometerKm'] as int);
  }

  // Get weekly distance statistics
  Future<Map<String, int>> getWeeklyStats(String bikeNumber) async {
    final db = await database;
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartStr = DateTime(weekStart.year, weekStart.month, weekStart.day).toIso8601String();
    
    final results = await db.query(
      'odometer_readings',
      where: 'bikeNumber = ? AND date >= ?',
      whereArgs: [bikeNumber, weekStartStr],
      orderBy: 'date ASC',
    );

    if (results.isEmpty) {
      return {'totalDistance': 0, 'avgDailyDistance': 0};
    }

    final firstReading = results.first['readingKm'] as int;
    final lastReading = results.last['readingKm'] as int;
    final totalDistance = lastReading - firstReading;

    // Calculate days passed in the week
    final daysPassed = results.length > 1
        ? DateTime.parse(results.last['date'] as String)
            .difference(DateTime.parse(results.first['date'] as String))
            .inDays + 1
        : 1;

    final avgDailyDistance = totalDistance ~/ daysPassed;

    return {
      'totalDistance': totalDistance,
      'avgDailyDistance': avgDailyDistance,
    };
  }

  // Get monthly distance statistics
  Future<Map<String, int>> getMonthlyStats(String bikeNumber) async {
    final db = await database;
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthStartStr = monthStart.toIso8601String();
    
    final results = await db.query(
      'odometer_readings',
      where: 'bikeNumber = ? AND date >= ?',
      whereArgs: [bikeNumber, monthStartStr],
      orderBy: 'date ASC',
    );

    if (results.isEmpty) {
      return {'totalDistance': 0, 'avgDailyDistance': 0};
    }

    final firstReading = results.first['readingKm'] as int;
    final lastReading = results.last['readingKm'] as int;
    final totalDistance = lastReading - firstReading;

    // Calculate days passed in the month
    final daysPassed = results.length > 1
        ? DateTime.parse(results.last['date'] as String)
            .difference(DateTime.parse(results.first['date'] as String))
            .inDays + 1
        : 1;

    final avgDailyDistance = totalDistance ~/ daysPassed;

    return {
      'totalDistance': totalDistance,
      'avgDailyDistance': avgDailyDistance,
    };
  }

  // Close the database
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
