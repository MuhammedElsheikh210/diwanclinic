// ignore_for_file: avoid_renaming_method_parameters
import '../../index/index_main.dart';

class AuthenticationDataSourceRepoImpl extends AuthenticationDataSourceRepo {
  final BaseSQLiteDataSourceRepo<Map<String, dynamic>> _sqliteRepo;

  AuthenticationDataSourceRepoImpl()
    : _sqliteRepo = BaseSQLiteDataSourceRepo<Map<String, dynamic>>(
        tableName: "clients",
        idColumn: "uid",
        // 🔥 أهم سطر
        fromJson: (json) => json,
        toJson: (model) => model,
        getId: (model) => model['uid'], // 🔥 لازم يطابق idColumn
      );

  // ============================================================
  // 🔹 LOCAL CLIENTS (Offline First)
  // ============================================================

  @override
  Future<List<LocalUser>> getClients(SQLiteQueryParams query) async {
    final finalQuery = SQLiteQueryParams(
      where:
          query.where != null
              ? "(${query.where}) AND (is_deleted IS NULL OR is_deleted = 0)"
              : "(is_deleted IS NULL OR is_deleted = 0)",
      whereArgs: query.whereArgs,
      orderBy: query.orderBy,
      limit: query.limit,
      offset: query.offset,
      groupBy: query.groupBy,
      having: query.having,
      distinct: query.distinct,
    );
    final result = await _sqliteRepo.getAll(query: finalQuery);

    return result.map((e) => LocalUser.fromMap(e)).toList();
  }

  @override
  Future<void> addClient(LocalUser model) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final json = model.toJson();

    json['updatedAt'] = now;
    json['serverUpdatedAt'] = 0;
    json['is_deleted'] = 0;

    await _sqliteRepo.addItem(json);
  }

  @override
  Future<void> updateClient(LocalUser model) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final json = model.toJson();

    json['updatedAt'] = now;

    await _sqliteRepo.updateItem(json);
  }

  @override
  Future<void> deleteClient(String key) async {
    final existing = await _sqliteRepo.getItem(key);
    if (existing == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;

    await _sqliteRepo.updateItem(existing);
  }

  // ============================================================
  // 🔹 SYNC ENGINE CONTROL
  // ============================================================

  @override
  Future<void> upsertFromServer(LocalUser serverModel) async {
    final json = serverModel.toJson();

    final key = json['uid'];
    if (key == null) return;

    final local = await _sqliteRepo.getItem(key);

    final serverTime =
        json['serverUpdatedAt'] ?? DateTime.now().millisecondsSinceEpoch;

    json['serverUpdatedAt'] = serverTime;
    json['updatedAt'] = serverTime;

    if (local == null) {
      await _sqliteRepo.addItem(json);
      return;
    }

    final localServerTime = _parseToInt(local['serverUpdatedAt']);

    if (serverTime >= localServerTime) {
      await _sqliteRepo.updateItem(json);
    }
  }

  int _parseToInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }

  @override
  Future<void> markAsSynced(String key, {int? serverUpdatedAt}) async {
    final local = await _sqliteRepo.getItem(key);
    if (local == null) return;

    final serverTime = serverUpdatedAt ?? DateTime.now().millisecondsSinceEpoch;

    local['serverUpdatedAt'] = serverTime;

    await _sqliteRepo.updateItem(local);
  }

  @override
  Future<List<LocalUser>> getPendingClients() async {
    final list = await _sqliteRepo.getAll(
      query: SQLiteQueryParams(
        where: "sync_status != ?",
        whereArgs: ['synced'],
      ),
    );

    return list.map((e) => LocalUser.fromMap(e)).toList();
  }
}
