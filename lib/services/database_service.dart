import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/vehicle.dart';
import '../models/maintenance_reminder.dart';
import '../models/fuel_record.dart';

class DatabaseService {
  static Database? _database;
  static const int _version = 5; // Increment version to fix table creation

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'car_maintenance.db');

    return openDatabase(
      path,
      version: _version,
      onCreate: (Database db, int version) async {
        await _createTables(db);
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < newVersion) {
          // Drop existing tables
          await db.execute('DROP TABLE IF EXISTS fuel_records');
          await db.execute('DROP TABLE IF EXISTS maintenance_records');
          await db.execute('DROP TABLE IF EXISTS maintenance_reminders');
          await db.execute('DROP TABLE IF EXISTS documents');
          await db.execute('DROP TABLE IF EXISTS vehicle_documents');
          await db.execute('DROP TABLE IF EXISTS trips');
          await db.execute('DROP TABLE IF EXISTS frequent_destinations');
          await db.execute('DROP TABLE IF EXISTS vehicles');
          
          // Recreate all tables
          await _createTables(db);
        }
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE vehicles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        make TEXT NOT NULL,
        model TEXT NOT NULL,
        year INTEGER NOT NULL,
        mileage INTEGER NOT NULL,
        vin TEXT,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE fuel_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicle_id INTEGER NOT NULL,
        date TIMESTAMP NOT NULL,
        gallons REAL NOT NULL,
        cost REAL NOT NULL,
        odometer INTEGER NOT NULL,
        location TEXT,
        is_full_tank INTEGER NOT NULL DEFAULT 1,
        notes TEXT,
        FOREIGN KEY (vehicle_id) REFERENCES vehicles (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE maintenance_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicle_id INTEGER NOT NULL,
        service_type TEXT NOT NULL,
        date TIMESTAMP NOT NULL,
        mileage INTEGER NOT NULL,
        notes TEXT,
        cost REAL,
        FOREIGN KEY (vehicle_id) REFERENCES vehicles (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE vehicle_documents (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicle_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        file_path TEXT NOT NULL,
        date TIMESTAMP NOT NULL,
        type TEXT NOT NULL,
        description TEXT,
        amount REAL,
        metadata TEXT,
        FOREIGN KEY (vehicle_id) REFERENCES vehicles (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE maintenance_reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicle_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        due_date TIMESTAMP,
        due_mileage INTEGER,
        frequency TEXT,
        repeat_miles INTEGER,
        is_completed INTEGER NOT NULL DEFAULT 0,
        notification_id TEXT,
        FOREIGN KEY (vehicle_id) REFERENCES vehicles (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE trips (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicle_id INTEGER NOT NULL,
        start_time TIMESTAMP NOT NULL,
        end_time TIMESTAMP,
        start_location TEXT,
        end_location TEXT,
        start_odometer REAL,
        end_odometer REAL,
        trip_type TEXT NOT NULL,
        purpose TEXT,
        fuel_cost REAL,
        notes TEXT,
        route_points TEXT,
        FOREIGN KEY (vehicle_id) REFERENCES vehicles (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE frequent_destinations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicle_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        visit_count INTEGER NOT NULL DEFAULT 1,
        last_visited TIMESTAMP NOT NULL,
        FOREIGN KEY (vehicle_id) REFERENCES vehicles (id) ON DELETE CASCADE
      )
    ''');
  }

  // Vehicle operations
  Future<int> insertVehicle(Vehicle vehicle) async {
    final db = await database;
    final map = <String, Object>{
      'make': vehicle.make,
      'model': vehicle.model,
      'year': vehicle.year,
      'mileage': vehicle.mileage,
    };
    
    // Only add non-null values
    if (vehicle.vin?.isNotEmpty ?? false) {
      map['vin'] = vehicle.vin!;
    }
    if (vehicle.imageUrl?.isNotEmpty ?? false) {
      map['imageUrl'] = vehicle.imageUrl!;
    }
    
    return await db.insert('vehicles', map);
  }

  Future<List<Vehicle>> getVehicles() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('vehicles');
    return List.generate(maps.length, (i) => Vehicle.fromMap(maps[i]));
  }

  Future<int> updateVehicle(Vehicle vehicle) async {
    final db = await database;
    return await db.update(
      'vehicles',
      vehicle.toMap(),
      where: 'id = ?',
      whereArgs: [vehicle.id],
    );
  }

  Future<int> deleteVehicle(int id) async {
    final db = await database;
    return await db.delete(
      'vehicles',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Maintenance Reminder operations
  Future<int> insertReminder(MaintenanceReminder reminder) async {
    final db = await database;
    return await db.insert('maintenance_reminders', reminder.toMap());
  }

  Future<List<MaintenanceReminder>> getReminders({int? vehicleId}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'maintenance_reminders',
      where: vehicleId != null ? 'vehicle_id = ?' : null,
      whereArgs: vehicleId != null ? [vehicleId] : null,
      orderBy: 'due_date ASC',
    );
    return List.generate(maps.length, (i) => MaintenanceReminder.fromMap(maps[i]));
  }

  Future<List<MaintenanceReminder>> getDueReminders() async {
    final db = await database;
    final now = DateTime.now();
    final List<Map<String, dynamic>> maps = await db.query(
      'maintenance_reminders',
      where: 'due_date <= ? AND is_completed = 0',
      whereArgs: [now.toIso8601String()],
      orderBy: 'due_date ASC',
    );
    return List.generate(maps.length, (i) => MaintenanceReminder.fromMap(maps[i]));
  }

  Future<int> updateReminder(MaintenanceReminder reminder) async {
    final db = await database;
    return await db.update(
      'maintenance_reminders',
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  Future<int> deleteReminder(int id) async {
    final db = await database;
    return await db.delete(
      'maintenance_reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Fuel record methods
  Future<List<FuelRecord>> getFuelRecords({int? vehicleId}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'fuel_records',
      where: vehicleId != null ? 'vehicle_id = ?' : null,
      whereArgs: vehicleId != null ? [vehicleId] : null,
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => FuelRecord.fromMap(maps[i]));
  }

  Future<int> insertFuelRecord(FuelRecord record) async {
    final db = await database;
    return await db.insert('fuel_records', record.toMap());
  }

  Future<int> updateFuelRecord(FuelRecord record) async {
    final db = await database;
    return await db.update(
      'fuel_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> deleteFuelRecord(int id) async {
    final db = await database;
    return await db.delete(
      'fuel_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Document operations
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<int> delete(String table, {String? where, List<dynamic>? whereArgs}) async {
    final db = await database;
    return await db.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(
      table,
      data,
      where: where,
      whereArgs: whereArgs,
    );
  }
}
