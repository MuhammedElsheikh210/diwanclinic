import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

abstract class ReservationRepository {
  // ============================================================
  // 🔥 REALTIME (Reservations Only)
  // ============================================================

  void startListening({
    required String doctorKey,
    required String date,
    required Function(ReservationModel model) onChanged,
    required Function(String key) onRemoved,
  });

  void dispose();

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
  // ⭐ PATIENT META (Remote Direct)
  // ============================================================

  Future<Either<AppError, SuccessModel>> addPatientReservationMetaDomain(
    ReservationModel meta,
    String patientKey,
  );

  Future<Either<AppError, SuccessModel>> updatePatientReservationDomain(
    ReservationModel meta,
    String key,
  );

  Future<Either<AppError, List<ReservationModel>>>
  getPatientReservationsMetaDomain(String patientKey);
}
