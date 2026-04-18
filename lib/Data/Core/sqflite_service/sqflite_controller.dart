import 'package:sqflite/sqlite_api.dart';
import '../../../index/index_main.dart';

class BaseSQLiteDataSourceRepo<T> {
  final String tableName;

  /// 🔥 dynamic id column (uid / key / anything)
  final String idColumn;

  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T model) toJson;
  final String? Function(T model) getId;

  final DatabaseService _dbService = DatabaseService();

  BaseSQLiteDataSourceRepo({
    required this.tableName,
    required this.idColumn, // 🔥 مهم
    required this.fromJson,
    required this.toJson,
    required this.getId,
  });

  Future<Database> get db async => await _dbService.database;

  // ============================================================
  // 🧱 BATCH
  // ============================================================

  Future<Batch> startBatch() async {
    final dbValue = await db;
    return dbValue.batch();
  }

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

  Future<void> commitBatch(Batch batch) async {
    await batch.commit(noResult: true);
  }

  // ============================================================
  // 📥 GET ALL
  // ============================================================

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

  // ============================================================
  // 📥 GET ONE
  // ============================================================

  Future<T?> getItem(String key) async {
    final dbValue = await db;

    try {
      final List<Map<String, dynamic>> maps = await dbValue.query(
        tableName,
        where: '$idColumn = ?', // 🔥 dynamic
        whereArgs: [key],
      );

      if (maps.isNotEmpty) {
        return fromJson(maps.first);
      }

      return null;
    } catch (e) {
      
      return null;
    }
  }

  // ============================================================
  // ➕ INSERT
  // ============================================================

  Future<void> addItem(T item) async {
    final dbValue = await db;
    final key = getId(item);

    if (key == null) {
      
      throw Exception("Key is null, cannot add item.");
    }

    try {
      final jsonData = toJson(item);

      
      
      
      
      

      final result = await dbValue.insert(
        tableName,
        jsonData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      

      // 🔥 VERIFY
      final verify = await dbValue.query(
        tableName,
        where: '$idColumn = ?', // 🔥 dynamic
        whereArgs: [key],
      );

      
    } catch (e, s) {
      
      
    }
  }

  // ============================================================
  // ✏️ UPDATE
  // ============================================================

  Future<void> updateItem(T item) async {
    final dbValue = await db;
    final key = getId(item);

    if (key == null) {
      throw Exception("❌ [ERROR] - Key is null, cannot update item.");
    }

    await dbValue.update(
      tableName,
      toJson(item),
      where: '$idColumn = ?', // 🔥 dynamic
      whereArgs: [key],
    );
  }

  // ============================================================
  // 🗑 DELETE
  // ============================================================

  Future<void> deleteItem(String key) async {
    final dbValue = await db;

    await dbValue.delete(
      tableName,
      where: '$idColumn = ?', // 🔥 dynamic
      whereArgs: [key],
    );
  }

  // ============================================================
  // 🔍 RAW QUERY
  // ============================================================

  Future<List<Map<String, dynamic>>> getRawQuery(
      String sql, [
        List<Object?>? args,
      ]) async {
    final dbValue = await db;
    return await dbValue.rawQuery(sql, args ?? []);
  }

  // ============================================================
  // 🎯 WHERE
  // ============================================================

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

  // ============================================================
  // 🗑 DELETE WHERE
  // ============================================================

  Future<void> deleteWhere(String where, List<Object?> whereArgs) async {
    final dbValue = await db;

    await dbValue.delete(
      tableName,
      where: where,
      whereArgs: whereArgs,
    );
  }
}