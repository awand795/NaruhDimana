import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/item_model.dart';
import '../../core/constants.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        location TEXT NOT NULL,
        category TEXT NOT NULL,
        tags TEXT,
        notes TEXT,
        photo_path TEXT,
        latitude REAL,
        longitude REAL,
        address TEXT,
        reminder_time TEXT,
        reminder_repeat TEXT DEFAULT 'none',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_items_name ON items(name)',
    );
    await db.execute(
      'CREATE INDEX idx_items_category ON items(category)',
    );
    await db.execute(
      'CREATE INDEX idx_items_created_at ON items(created_at)',
    );
  }

  Future<int> insertItem(Item item) async {
    final db = await database;
    return await db.insert('items', item.toMap());
  }

  Future<int> updateItem(Item item) async {
    final db = await database;
    return await db.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Item?> getItem(int id) async {
    final db = await database;
    final maps = await db.query(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Item.fromMap(maps.first);
  }

  Future<List<Item>> getAllItems() async {
    final db = await database;
    final maps = await db.query(
      'items',
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Item.fromMap(map)).toList();
  }

  Future<List<Item>> getRecentItems(int limit) async {
    final db = await database;
    final maps = await db.query(
      'items',
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return maps.map((map) => Item.fromMap(map)).toList();
  }

  Future<List<Item>> searchItems(String query) async {
    final db = await database;
    final searchPattern = '%$query%';
    final maps = await db.query(
      'items',
      where: 'name LIKE ? OR location LIKE ? OR notes LIKE ? OR tags LIKE ?',
      whereArgs: [searchPattern, searchPattern, searchPattern, searchPattern],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Item.fromMap(map)).toList();
  }

  Future<List<Item>> getItemsByCategory(String category) async {
    final db = await database;
    final maps = await db.query(
      'items',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Item.fromMap(map)).toList();
  }

  Future<Map<String, int>> getCategoryCounts() async {
    final db = await database;
    final maps = await db.rawQuery(
      'SELECT category, COUNT(*) as count FROM items GROUP BY category',
    );
    final counts = <String, int>{};
    for (final map in maps) {
      counts[map['category'] as String] = map['count'] as int;
    }
    return counts;
  }

  Future<int> getItemCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM items');
    return (result.first['count'] as int?) ?? 0;
  }

  Future<int> getItemsWithRemindersCount() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM items WHERE reminder_time IS NOT NULL",
    );
    return (result.first['count'] as int?) ?? 0;
  }

  Future<int> getItemsWithGpsCount() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM items WHERE latitude IS NOT NULL AND longitude IS NOT NULL",
    );
    return (result.first['count'] as int?) ?? 0;
  }

  Future<List<Item>> getFilteredItems({
    String? searchQuery,
    String? category,
    bool? hasPhoto,
    bool? hasGps,
    bool? hasReminder,
    String sortBy = 'newest',
  }) async {
    final db = await database;
    final conditions = <String>[];
    final whereArgs = <dynamic>[];

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final pattern = '%$searchQuery%';
      conditions.add(
        '(name LIKE ? OR location LIKE ? OR notes LIKE ? OR tags LIKE ?)',
      );
      whereArgs.addAll([pattern, pattern, pattern, pattern]);
    }

    if (category != null && category.isNotEmpty) {
      conditions.add('category = ?');
      whereArgs.add(category);
    }

    if (hasPhoto == true) {
      conditions.add('photo_path IS NOT NULL AND photo_path != ""');
    }

    if (hasGps == true) {
      conditions.add(
        'latitude IS NOT NULL AND longitude IS NOT NULL',
      );
    }

    if (hasReminder == true) {
      conditions.add('reminder_time IS NOT NULL');
    }

    String orderBy;
    switch (sortBy) {
      case 'az':
        orderBy = 'name ASC';
        break;
      case 'category':
        orderBy = 'category ASC, name ASC';
        break;
      default:
        orderBy = 'created_at DESC';
    }

    final query = conditions.isEmpty
        ? 'SELECT * FROM items ORDER BY $orderBy'
        : 'SELECT * FROM items WHERE ${conditions.join(' AND ')} ORDER BY $orderBy';

    final maps = await db.rawQuery(query, whereArgs);
    return maps.map((map) => Item.fromMap(map)).toList();
  }

  Future<List<Item>> getItemsWithPendingReminders() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final maps = await db.query(
      'items',
      where: 'reminder_time IS NOT NULL AND reminder_time <= ?',
      whereArgs: [now],
    );
    return maps.map((map) => Item.fromMap(map)).toList();
  }
}
