import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

class ReservationRepositoryImpl extends ReservationRepository {
  final ReservationDataSourceRepo _reservationDataSourceRepo;

  ReservationRepositoryImpl(this._reservationDataSourceRepo);

  // ------------------------------------------------------------
  // 🔹 GET
  // ------------------------------------------------------------
  @override
  Future<Either<AppError, List<ReservationModel?>>> getReservationsDomain(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? fromOnline,
    bool? isFiltered,
    String date, {
    bool isPatient = false,
    String? doctorUid,
  }) async {
    try {
      final result = await _reservationDataSourceRepo.getReservations(
        data,
        query,
        fromOnline,
        isFiltered,
        date,
        isPatient: isPatient,
        doctorUid: doctorUid,
      );

      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  // ------------------------------------------------------------
  // 🔹 ADD
  // ------------------------------------------------------------
  @override
  Future<Either<AppError, SuccessModel>> addReservationDomain(
    Map<String, dynamic> data,
    String key,
    String date, {
    bool localOnly = false,
    bool isPatient = false,
    String? doctorUid,
  }) async {
    try {
      final result = await _reservationDataSourceRepo.addReservation(
        data,
        key,
        date,
        localOnly: localOnly,
        isPatient: isPatient,
        doctorUid: doctorUid,
      );

      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  // ------------------------------------------------------------
  // 🔹 BULK (Not supported here)
  // ------------------------------------------------------------
  @override
  Future<Either<AppError, SuccessModel>> addReservationBulkDomain(
    Map<String, Map<String, dynamic>> bulkData,
    String date, {
    bool localOnly = false,
    bool isPatient = false,
    String? doctorUid,
  }) async {
    return Left(AppError("Bulk is not handled here anymore"));
  }

  // ------------------------------------------------------------
  // 🔹 DELETE
  // ------------------------------------------------------------
  @override
  Future<Either<AppError, SuccessModel>> deleteReservationDomain(
    Map<String, dynamic> data,
    String key,
    String date, {
    bool isPatient = false,
    String? doctorUid,
  }) async {
    try {
      final result = await _reservationDataSourceRepo.deleteReservation(
        data,
        key,
        date,
        isPatient: isPatient,
        doctorUid: doctorUid,
      );

      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  // ------------------------------------------------------------
  // 🔹 UPDATE
  // ------------------------------------------------------------
  @override
  Future<Either<AppError, SuccessModel>> updateReservationDomain(
    Map<String, dynamic> data,
    String key,
    String date, {
    bool localOnly = false,
    bool isPatient = false,
    String? doctorUid,
  }) async {
    try {
      final result = await _reservationDataSourceRepo.updateReservation(
        data,
        key,
        date,
        localOnly: localOnly,
        isPatient: isPatient,
        doctorUid: doctorUid,
      );

      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  // ------------------------------------------------------------
  // ⭐ NEW: ADD Patient Reservation Meta
  // ------------------------------------------------------------
  @override
  Future<Either<AppError, SuccessModel>> addPatientReservationMetaDomain(
    ReservationModel meta,
    String patientKey,
  ) async {
    try {
      final result = await _reservationDataSourceRepo.addPatientReservationMeta(
        meta,
        patientKey,
      );

      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }


  // ------------------------------------------------------------
  // ⭐ NEW: GET Patient Reservation Meta
  // ------------------------------------------------------------
  @override
  Future<Either<AppError, List<ReservationModel>>>
  getPatientReservationsMetaDomain(String patientKey) async {
    try {
      final result = await _reservationDataSourceRepo
          .getPatientReservationsMeta(patientKey);

      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  /// ⭐ NEW
  @override
  Future<Either<AppError, SuccessModel>> updatePatientReservationDomain(
      ReservationModel meta,
    String key,
  ) async {
    try {
      final result = await _reservationDataSourceRepo.updatePatientReservation(
        meta,
        key,
      );
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }
}
