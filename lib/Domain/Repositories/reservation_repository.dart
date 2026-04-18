import 'package:dartz/dartz.dart';

import '../../index/index_main.dart';

abstract class ReservationRepository {
  // ============================================================
  // 🔥 REALTIME CONTROL (Firebase → SQLite Sync Only)
  // ============================================================

  Future<void> startListening({required String doctorKey});

  Future<void> stopListening();

  Future<void> dispose();

  // ============================================================
  // 🔥 REALTIME STREAMS (Expose to upper layers)
  // ============================================================

  Stream<ReservationModel> get onAdded;

  Stream<ReservationModel> get onChanged;

  Stream<String> get onRemoved;

  // ============================================================
  // 🔹 LOCAL RESERVATIONS (Offline First)
  // ============================================================

  Future<Either<AppError, List<ReservationModel?>>> getReservationsDomain(
    SQLiteQueryParams query,
  );

  Future<Either<AppError, Unit>> addReservationDomain(ReservationModel model);

  Future<Either<AppError, Unit>> updateReservationDomain(
    ReservationModel model,
  );

  Future<Either<AppError, Unit>> deleteReservationDomain(String key);

  // ============================================================
// 📥 PATIENT FETCH (REMOTE ONLY)
// ============================================================

  Future<Either<AppError, List<ReservationModel>>>
  fetchReservationsOnceDomain({
    required String doctorKey,
    required String date, // yyyy-MM-dd
  });

  // ============================================================
  // ⭐ PATIENT META (Remote Direct)
  // ============================================================

  // Future<Either<AppError, SuccessModel>> addPatientReservationMetaDomain(
  //   ReservationModel meta,
  //   String patientKey,
  // );
  //
  // Future<Either<AppError, SuccessModel>> updatePatientReservationDomain(
  //   ReservationModel meta,
  //   String key,
  // );
  //
  // Future<Either<AppError, List<ReservationModel>>>
  // getPatientReservationsMetaDomain(String patientKey);
}
