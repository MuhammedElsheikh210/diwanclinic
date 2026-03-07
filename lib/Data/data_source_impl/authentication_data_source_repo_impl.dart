// ignore_for_file: avoid_renaming_method_parameters
import '../../index/index_main.dart';

class AuthenticationDataSourceRepoImpl extends AuthenticationDataSourceRepo {
  final BaseSQLiteDataSourceRepo<LocalUser> _sqliteRepo;

  AuthenticationDataSourceRepoImpl()
    : _sqliteRepo = BaseSQLiteDataSourceRepo<LocalUser>(
        tableName: "clients",
        fromJson: (json) => LocalUser.fromJson(json),
        toJson: (model) => model.toJson(),
        getId: (model) => model.key,
      );

  // ============================================================
  // 🔹 LOCAL CLIENTS (Offline First)
  // ============================================================

  @override
  Future<List<LocalUser?>> getClients(SQLiteQueryParams query) async {
    final finalQuery = SQLiteQueryParams(
      where:
          query.where != null
              ? "(${query.where}) AND is_deleted = 0"
              : "is_deleted = 0",
      whereArgs: query.whereArgs,
      orderBy: query.orderBy,
      limit: query.limit,
      offset: query.offset,
      groupBy: query.groupBy,
      having: query.having,
      distinct: query.distinct,
    );

    return await _sqliteRepo.getAll(query: finalQuery);
  }

  @override
  Future<void> addClient(LocalUser model) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final newModel = model.copyWith(
      updatedAt: now,
      serverUpdatedAt: 0,
      isDeleted: false,
    );

    await _sqliteRepo.addItem(newModel);
  }

  @override
  Future<void> updateClient(LocalUser model) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final updated = model.copyWith(updatedAt: now);

    await _sqliteRepo.updateItem(updated);
  }

  @override
  Future<void> deleteClient(String key) async {
    final existing = await _sqliteRepo.getItem(key);
    if (existing == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;

    final deleted = existing.copyWith(isDeleted: true, updatedAt: now);

    await _sqliteRepo.updateItem(deleted);
  }

  // ============================================================
  // 🔹 SYNC ENGINE CONTROL
  // ============================================================

  @override
  Future<void> upsertFromServer(LocalUser serverModel) async {
    if (serverModel.key == null) return;

    final local = await _sqliteRepo.getItem(serverModel.key!);

    final serverTime =
        serverModel.serverUpdatedAt ?? DateTime.now().millisecondsSinceEpoch;

    if (local == null) {
      await _sqliteRepo.addItem(
        serverModel.copyWith(
          serverUpdatedAt: serverTime,
          updatedAt: serverTime,
        ),
      );
      return;
    }

    if (serverTime >= (local.serverUpdatedAt ?? 0)) {
      await _sqliteRepo.updateItem(
        serverModel.copyWith(
          serverUpdatedAt: serverTime,
          updatedAt: serverTime,
        ),
      );
    }
  }

  @override
  Future<void> markAsSynced(String key, {int? serverUpdatedAt}) async {
    final local = await _sqliteRepo.getItem(key);
    if (local == null) return;

    final serverTime = serverUpdatedAt ?? DateTime.now().millisecondsSinceEpoch;

    await _sqliteRepo.updateItem(local.copyWith(serverUpdatedAt: serverTime));
  }

  @override
  Future<List<LocalUser>> getPendingClients() async {
    final list = await _sqliteRepo.getAll(
      query: SQLiteQueryParams(
        where: "sync_status != ?",
        whereArgs: ['synced'],
      ),
    );

    return list.whereType<LocalUser>().toList();
  }
}
