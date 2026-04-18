import '../../index/index_main.dart';

abstract class ReservationDataSourceRepo {
  // ============================================================
  // 🔹 LOCAL RESERVATIONS (Offline First)
  // ============================================================

  /// Always read from SQLite (source of truth for UI)
  Future<List<ReservationModel?>> getReservations(SQLiteQueryParams query);

  /// Optimistic add (syncStatus = pendingCreate)
  Future<void> addReservation(ReservationModel model);

  /// Optimistic update (pendingUpdate)
  Future<void> updateReservation(ReservationModel model);

  /// Soft delete (pendingDelete + isDeleted = true)
  Future<void> deleteReservation(String key);

  // ============================================================
  // 🔹 SYNC ENGINE CONTROL
  // ============================================================

  /// Called when server pushes data (Realtime)
  Future<void> upsertFromServer(ReservationModel model);

  /// Mark local record as synced after successful push
  Future<void> markAsSynced(String key, {int? serverUpdatedAt});

  /// Get all non-synced records (for SyncWorker)
  Future<List<ReservationModel>> getPendingReservations();

  // ============================================================
  // ⭐ PATIENT META (Remote Direct - Separate Firebase Path)
  // ============================================================

  // /// Add patient reservation meta (Remote Only)
  // Future<SuccessModel> addPatientReservationMeta(
  //   ReservationModel meta,
  //   String patientKey,
  // );
  //
  // /// Update patient reservation meta (Remote Only)
  // Future<SuccessModel> updatePatientReservation(
  //   ReservationModel meta,
  //   String key,
  // );
  //
  // /// Get patient reservation meta list (Remote Only)
  // Future<List<ReservationModel>> getPatientReservationsMeta(String patientKey);
}
