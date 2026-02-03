import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

abstract class ReservationRepository {
  /// 🔍 Get reservations for a specific date folder (Doctor-side or Patient-side)
  Future<Either<AppError, List<ReservationModel?>>> getReservationsDomain(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? fromOnline,
    bool? isFiltered,
    String date, {
    bool isPatient = false,
    String? doctorUid,
  });


  /// ➕ Add reservation
  Future<Either<AppError, SuccessModel>> addReservationDomain(
    Map<String, dynamic> data,
    String key,
    String date, {
    bool localOnly = false,
    bool isPatient = false,
    String? doctorUid,
  });

  /// 🔥 BULK Add (Separated Logic)
  Future<Either<AppError, SuccessModel>> addReservationBulkDomain(
    Map<String, Map<String, dynamic>> bulkData,
    String date, {
    bool localOnly = false,
    bool isPatient = false,
    String? doctorUid,
  });

  /// ❌ Delete reservation
  Future<Either<AppError, SuccessModel>> deleteReservationDomain(
    Map<String, dynamic> data,
    String key,
    String date, {
    bool isPatient = false,
    String? doctorUid,
  });

  /// 🔄 Update reservation
  Future<Either<AppError, SuccessModel>> updateReservationDomain(
    Map<String, dynamic> data,
    String key,
    String date, {
    bool localOnly = false,
    bool isPatient = false,
    String? doctorUid,
  });

  Future<Either<AppError, SuccessModel>> updatePatientReservationDomain(
      ReservationModel meta,
    String key,
  );

  // --------------------------------------------------------------------
  // ⭐ NEW: Patient Reservation META
  // --------------------------------------------------------------------

  /// ➕ Add metadata for patient reservation
  Future<Either<AppError, SuccessModel>> addPatientReservationMetaDomain(
    ReservationModel meta,
    String patientKey,
  );

  /// 🔍 Get all metadata reservations for this patient
  Future<Either<AppError, List<ReservationModel>>>
  getPatientReservationsMetaDomain(String patientKey);
}
