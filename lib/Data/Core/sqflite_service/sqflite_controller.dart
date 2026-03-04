import 'package:sqflite/sqlite_api.dart';
import '../../../index/index_main.dart';
import 'sqflite_service.dart'; // Replace with the correct import path

class BaseSQLiteDataSourceRepo<T> {
  final String tableName;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T model) toJson;
  final String? Function(T model) getId;

  final DatabaseService _dbService =
      DatabaseService(); // Only one instance of DatabaseService

  BaseSQLiteDataSourceRepo({
    required this.tableName,
    required this.fromJson,
    required this.toJson,
    required this.getId,
  });

  Future<Database> get db async =>
      await _dbService.database; // Reuse the same database instance

  /// ✅ Start a batch operation.
  Future<Batch> startBatch() async {
    final dbValue = await db;
    return dbValue.batch();
  }

  /// ✅ Add an item within a batch operation.
  void addItemWithBatch(Batch batch, T item) {
    final key = getId(item);
    if (key == null) {
      throw Exception("❌ [ERROR] - Key is null, cannot add item in batch.");
    }
    batch.insert(
      tableName,
      toJson(item),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// ✅ Commit a batch operation.
  Future<void> commitBatch(Batch batch) async {
    await batch.commit(noResult: true);
  }

  /// Get all items from the table.
  Future<List<T>> getAll({SQLiteQueryParams? query}) async {
    final dbValue = await db;
    try {
      final List<Map<String, dynamic>> maps = await dbValue.query(
        tableName,
        orderBy: query?.orderBy,
        where: query?.where,
        whereArgs: query?.whereArgs,
        distinct: query?.distinct,
        having: query?.having,
        limit: query?.limit,
        offset: query?.offset,
        groupBy: query?.groupBy,
      );
      return maps.map((map) => fromJson(map)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get a single item using a key.
  Future<T?> getItem(String key) async {
    final dbValue = await db;
    try {
      final List<Map<String, dynamic>> maps = await dbValue.query(
        tableName,
        where: 'key = ?',
        whereArgs: [key],
      );
      if (maps.isNotEmpty) {
        return fromJson(maps.first);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> addItem(T item) async {
    final dbValue = await db;
    final key = getId(item);

    if (key == null) {
      print("❌ SQLITE ADD FAILED → Key is NULL");
      throw Exception("Key is null, cannot add item.");
    }

    try {
      final jsonData = toJson(item);

      print("🟢 SQLITE INSERT START");
      print("Table: $tableName");
      print("Key: $key");
      print("Data: $jsonData");

      final result = await dbValue.insert(
        tableName,
        jsonData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print("✅ SQLITE INSERT SUCCESS → rowId: $result");

      // 🔥 Verify immediately after insert
      final verify = await dbValue.query(
        tableName,
        where: 'key = ?',
        whereArgs: [key],
      );

      print("🔎 VERIFY COUNT: ${verify.length}");
    } catch (e, s) {
      print("❌ SQLITE INSERT ERROR: $e");
      print("STACK: $s");
    }
  }

  /// Update an existing item.
  Future<void> updateItem(T item) async {
    final dbValue = await db;
    final key = getId(item);
    if (key == null) {
      throw Exception("❌ [ERROR] - Key is null, cannot update item.");
    }
    await dbValue.update(
      tableName,
      toJson(item),
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  /// Delete an item.
  Future<void> deleteItem(String key) async {
    final dbValue = await db;
    await dbValue.delete(tableName, where: 'key = ?', whereArgs: [key]);
  }

  /// ✅ Run raw SQL query
  Future<List<Map<String, dynamic>>> getRawQuery(
    String sql, [
    List<Object?>? args,
  ]) async {
    final dbValue = await db;
    return await dbValue.rawQuery(sql, args ?? []);
  }

  /// ✅ Get items with custom WHERE condition
  Future<List<T>> getWhere({
    required String where,
    required List<Object?> whereArgs,
  }) async {
    final dbValue = await db;
    final result = await dbValue.query(
      tableName,
      where: where,
      whereArgs: whereArgs,
    );
    return result.map((map) => fromJson(map)).toList();
  }

  /// ✅ Delete with custom WHERE condition
  Future<void> deleteWhere(String where, List<Object?> whereArgs) async {
    final dbValue = await db;
    await dbValue.delete(tableName, where: where, whereArgs: whereArgs);
  }
}
