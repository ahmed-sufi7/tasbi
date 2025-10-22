import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import '../models/durood.dart';
import '../models/counter_session.dart';
import '../config/app_config.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConfig.databaseName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: AppConfig.databaseVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const boolType = 'INTEGER NOT NULL';

    // Create Duroods table
    await db.execute('''
      CREATE TABLE duroods (
        id $idType,
        name $textType,
        arabic $textType,
        transliteration TEXT,
        translation TEXT,
        target $intType,
        isDefault $boolType,
        createdAt $textType,
        updatedAt TEXT
      )
    ''');

    // Create Counter Sessions table
    await db.execute('''
      CREATE TABLE counter_sessions (
        id $idType,
        duroodId $textType,
        count $intType,
        target $intType,
        startTime $textType,
        endTime TEXT,
        isCompleted $boolType,
        notes TEXT,
        FOREIGN KEY (duroodId) REFERENCES duroods (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better performance
    await db.execute('''
      CREATE INDEX idx_counter_sessions_duroodId 
      ON counter_sessions(duroodId)
    ''');

    await db.execute('''
      CREATE INDEX idx_counter_sessions_startTime 
      ON counter_sessions(startTime)
    ''');

    // Insert default duroods
    await _insertDefaultDuroods(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < 2) {
      // Update default duroods with Arabic names
      await _updateDefaultDuroods(db);
    }
  }

  Future<void> _insertDefaultDuroods(Database db) async {
    const uuid = Uuid();
    for (var duroodData in AppConfig.defaultDuroods) {
      final durood = Durood(
        id: uuid.v4(),
        name: duroodData['name'] as String,
        arabic: duroodData['arabic'] as String,
        transliteration: duroodData['transliteration'] as String?,
        translation: duroodData['translation'] as String?,
        target: duroodData['target'] as int,
        isDefault: duroodData['isDefault'] as bool,
      );
      await db.insert('duroods', durood.toMap());
    }
  }

  /// Update existing default duroods with new Arabic names
  Future<void> _updateDefaultDuroods(Database db) async {
    // Get current default duroods
    final currentDefaults = await db.query(
      'duroods',
      where: 'isDefault = ?',
      whereArgs: [1],
    );
    
    // First, specifically update the Salawat tasbi to Salawat/Durood
    final salawatDurood = currentDefaults.firstWhere(
      (d) => d['arabic'] == 'صَلَّى ٱللّٰهُ عَلَيْهِ وَآلِهِ وَسَلَّمَ' && d['name'] == 'Salawat',
      orElse: () => <String, dynamic>{},
    );
    
    if (salawatDurood.isNotEmpty) {
      final updatedSalawat = Durood.fromMap(salawatDurood).copyWith(
        name: 'Salawat/Durood',
        updatedAt: DateTime.now(),
      );
      
      await db.update(
        'duroods',
        updatedSalawat.toMap(),
        where: 'id = ?',
        whereArgs: [updatedSalawat.id],
      );
    }
    
    // Update each default durood with new data from AppConfig
    for (var duroodData in AppConfig.defaultDuroods) {
      // Find matching durood by transliteration (which should be unique)
      final matchingDurood = currentDefaults.firstWhere(
        (d) => d['transliteration'] == duroodData['transliteration'],
        orElse: () => <String, dynamic>{},
      );
      
      // If found, update it with new Arabic name
      if (matchingDurood.isNotEmpty) {
        final updatedDurood = Durood.fromMap(matchingDurood).copyWith(
          name: duroodData['name'] as String,
          arabic: duroodData['arabic'] as String,
          updatedAt: DateTime.now(),
        );
        
        await db.update(
          'duroods',
          updatedDurood.toMap(),
          where: 'id = ?',
          whereArgs: [updatedDurood.id],
        );
      }
    }
  }

  /// Public method to update default duroods with Arabic names
  Future<void> updateDefaultDuroods() async {
    final db = await database;
    await _updateDefaultDuroods(db);
  }
  Future<String> createDurood(Durood durood) async {
    final db = await database;
    const uuid = Uuid();
    final id = uuid.v4();
    final newDurood = durood.copyWith(id: id);
    await db.insert('duroods', newDurood.toMap());
    return id;
  }

  Future<Durood?> getDurood(String id) async {
    final db = await database;
    final maps = await db.query(
      'duroods',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Durood.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Durood>> getAllDuroods() async {
    final db = await database;
    final orderBy = 'isDefault DESC, createdAt DESC';
    final result = await db.query('duroods', orderBy: orderBy);
    return result.map((map) => Durood.fromMap(map)).toList();
  }

  Future<List<Durood>> getCustomDuroods() async {
    final db = await database;
    final result = await db.query(
      'duroods',
      where: 'isDefault = ?',
      whereArgs: [0],
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => Durood.fromMap(map)).toList();
  }

  Future<Durood?> getDefaultUnlimitedDurood() async {
    final db = await database;
    final result = await db.query(
      'duroods',
      where: 'isDefault = ? AND target = ?',
      whereArgs: [1, 0],
    );
    
    if (result.isNotEmpty) {
      return Durood.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateDurood(Durood durood) async {
    final db = await database;
    return db.update(
      'duroods',
      durood.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [durood.id],
    );
  }

  Future<int> deleteDurood(String id) async {
    final db = await database;
    return await db.delete(
      'duroods',
      where: 'id = ? AND isDefault = ?',
      whereArgs: [id, 0], // Only allow deletion of custom duroods
    );
  }

  // CRUD operations for Counter Session
  Future<String> createSession(CounterSession session) async {
    final db = await database;
    const uuid = Uuid();
    final id = uuid.v4();
    final newSession = session.copyWith(id: id);
    await db.insert('counter_sessions', newSession.toMap());
    return id;
  }

  Future<CounterSession?> getSession(String id) async {
    final db = await database;
    final maps = await db.query(
      'counter_sessions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return CounterSession.fromMap(maps.first);
    }
    return null;
  }

  Future<List<CounterSession>> getAllSessions() async {
    final db = await database;
    final result = await db.query(
      'counter_sessions',
      orderBy: 'startTime DESC',
    );
    return result.map((map) => CounterSession.fromMap(map)).toList();
  }

  Future<List<CounterSession>> getSessionsByDurood(String duroodId) async {
    final db = await database;
    final result = await db.query(
      'counter_sessions',
      where: 'duroodId = ?',
      whereArgs: [duroodId],
      orderBy: 'startTime DESC',
    );
    return result.map((map) => CounterSession.fromMap(map)).toList();
  }

  Future<List<CounterSession>> getCompletedSessions() async {
    final db = await database;
    final result = await db.query(
      'counter_sessions',
      where: 'isCompleted = ?',
      whereArgs: [1],
      orderBy: 'startTime DESC',
    );
    return result.map((map) => CounterSession.fromMap(map)).toList();
  }

  Future<List<CounterSession>> getSessionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final result = await db.query(
      'counter_sessions',
      where: 'startTime BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'startTime DESC',
    );
    return result.map((map) => CounterSession.fromMap(map)).toList();
  }

  Future<int> updateSession(CounterSession session) async {
    final db = await database;
    return db.update(
      'counter_sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<int> deleteSession(String id) async {
    final db = await database;
    return await db.delete(
      'counter_sessions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllSessions() async {
    final db = await database;
    return await db.delete('counter_sessions');
  }

  // Statistics
  Future<Map<String, dynamic>> getStatistics() async {
    final db = await database;
    
    // Total count across all sessions (completed and saved but incomplete)
    final totalCountResult = await db.rawQuery(
      'SELECT SUM(count) as total FROM counter_sessions WHERE isCompleted = 1 OR count > 0'
    );
    final totalCount = totalCountResult.first['total'] as int? ?? 0;

    // Total completed sessions
    final completedSessionsResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM counter_sessions WHERE isCompleted = 1'
    );
    final completedSessions = completedSessionsResult.first['count'] as int? ?? 0;

    // Count by durood (including saved but incomplete sessions)
    final countByDuroodResult = await db.rawQuery('''
      SELECT d.name, SUM(cs.count) as total
      FROM counter_sessions cs
      JOIN duroods d ON cs.duroodId = d.id
      WHERE cs.isCompleted = 1 OR cs.count > 0
      GROUP BY cs.duroodId
      ORDER BY total DESC
    ''');

    return {
      'totalCount': totalCount,
      'completedSessions': completedSessions,
      'countByDurood': countByDuroodResult,
    };
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }

  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConfig.databaseName);
    await deleteDatabase(path);
    _database = null;
  }
}
