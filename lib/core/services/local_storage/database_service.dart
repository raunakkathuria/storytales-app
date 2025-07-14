import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Service for managing the local SQLite database.
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  /// Factory constructor to return the same instance every time
  factory DatabaseService() => _instance;

  /// Private constructor for singleton pattern
  DatabaseService._internal();

  /// Get the database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'storytales.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  /// Create the database tables
  Future<void> _onCreate(Database db, int version) async {
    // Stories table
    await db.execute('''
      CREATE TABLE stories (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        summary TEXT NOT NULL,
        cover_image_path TEXT NOT NULL,
        created_at TEXT NOT NULL,
        author TEXT NOT NULL,
        age_range TEXT NOT NULL,
        reading_time TEXT NOT NULL,
        original_prompt TEXT NOT NULL,
        genre TEXT NOT NULL,
        theme TEXT NOT NULL,
        is_pregenerated INTEGER NOT NULL,
        is_favorite INTEGER NOT NULL
      )
    ''');

    // Story Tags table
    await db.execute('''
      CREATE TABLE story_tags (
        id TEXT PRIMARY KEY,
        story_id TEXT NOT NULL,
        tag TEXT NOT NULL,
        FOREIGN KEY (story_id) REFERENCES stories (id) ON DELETE CASCADE
      )
    ''');

    // Story Pages table
    await db.execute('''
      CREATE TABLE story_pages (
        id TEXT PRIMARY KEY,
        story_id TEXT NOT NULL,
        page_number INTEGER NOT NULL,
        content TEXT NOT NULL,
        image_path TEXT NOT NULL,
        FOREIGN KEY (story_id) REFERENCES stories (id) ON DELETE CASCADE
      )
    ''');

    // Story Questions table
    await db.execute('''
      CREATE TABLE story_questions (
        id TEXT PRIMARY KEY,
        story_id TEXT NOT NULL,
        question_text TEXT NOT NULL,
        question_order INTEGER NOT NULL,
        FOREIGN KEY (story_id) REFERENCES stories (id) ON DELETE CASCADE
      )
    ''');
  }

  /// Close the database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Insert a record into the database
  Future<int> insert(String table, Map<String, dynamic> data) async {
    Database db = await database;
    return await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Insert multiple records into the database in a transaction
  Future<void> insertBatch(
      String table, List<Map<String, dynamic>> dataList) async {
    Database db = await database;
    Batch batch = db.batch();
    for (var data in dataList) {
      batch.insert(
        table,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Update a record in the database
  Future<int> update(
      String table, Map<String, dynamic> data, String whereClause) async {
    Database db = await database;
    return await db.update(
      table,
      data,
      where: whereClause,
      whereArgs: [data['id']],
    );
  }

  /// Delete a record from the database
  Future<int> delete(String table, String id) async {
    Database db = await database;
    return await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Query the database
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    Database db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  /// Execute a raw SQL query
  Future<List<Map<String, dynamic>>> rawQuery(
      String sql, List<dynamic> arguments) async {
    Database db = await database;
    return await db.rawQuery(sql, arguments);
  }

  /// Execute a raw SQL command
  Future<int> rawExecute(String sql, List<dynamic> arguments) async {
    Database db = await database;
    return await db.rawUpdate(sql, arguments);
  }

  /// Execute multiple operations in a transaction
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    Database db = await database;
    return await db.transaction(action);
  }
}
