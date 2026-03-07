import '../../index/index_main.dart';

abstract class AuthenticationDataSourceRepo {
  // ============================================================
  // 🔹 LOCAL CLIENTS (Offline First)
  // ============================================================

  /// Always read from SQLite (source of truth for UI)
  Future<List<LocalUser?>> getClients(SQLiteQueryParams query);

  /// Optimistic add (syncStatus = pendingCreate)
  Future<void> addClient(LocalUser model);

  /// Optimistic update (pendingUpdate)
  Future<void> updateClient(LocalUser model);

  /// Soft delete (pendingDelete + isDeleted = true)
  Future<void> deleteClient(String key);

  // ============================================================
  // 🔹 SYNC ENGINE CONTROL
  // ============================================================

  /// Called when server pushes data (Realtime)
  Future<void> upsertFromServer(LocalUser model);

  /// Mark local record as synced after successful push
  Future<void> markAsSynced(String key, {int? serverUpdatedAt});

  /// Get all non-synced records (for SyncWorker)
  Future<List<LocalUser>> getPendingClients();
}
