import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class ReservationUseCases {
  final ReservationRepository _repository;

  ReservationUseCases(this._repository);

  // ------------------------------------------------------------
  // 🔹 ADD RESERVATION
  // ------------------------------------------------------------
  Future<Either<AppError, SuccessModel>> addReservation(
    ReservationModel reservation,
    String date, {
    bool localOnly = false,
    bool isPatient = false,
    String? doctorUid,
  }) {
    return _repository.addReservationDomain(
      reservation.toJson(),
      reservation.key ?? "",
      date,
      localOnly: localOnly,
      isPatient: isPatient,
      doctorUid: doctorUid,
    );
  }

  // ------------------------------------------------------------
  // 🔹 UPDATE RESERVATION
  // ------------------------------------------------------------
  Future<Either<AppError, SuccessModel>> updateReservation(
    ReservationModel reservation, {
    bool localOnly = false,
    required String date,
    bool isPatient = false,
    String? doctorUid,
  }) {
    return _repository.updateReservationDomain(
      reservation.toJson(),
      reservation.key ?? "",
      date,
      localOnly: localOnly,
      isPatient: isPatient,
      doctorUid: doctorUid,
    );
  }

  // ------------------------------------------------------------
  // 🔹 DELETE RESERVATION
  // ------------------------------------------------------------
  Future<Either<AppError, SuccessModel>> deleteReservation(
    String key,
    String date, {
    bool isPatient = false,
    String? doctorUid,
  }) {
    return _repository.deleteReservationDomain(
      {},
      key,
      date,
      isPatient: isPatient,
      doctorUid: doctorUid,
    );
  }

  // ------------------------------------------------------------
  // 🔹 GET RESERVATIONS (LIST)
  // ------------------------------------------------------------
  Future<Either<AppError, List<ReservationModel?>>> getReservations(
    FirebaseFilter data,
    SQLiteQueryParams query,
    bool? fromOnline,
    String date, {
    bool isPatient = false,
    String? doctorUid,
  }) {
    return _repository.getReservationsDomain(
      data.toJson(),
      query,
      fromOnline,
      query.is_filtered,
      date,
      isPatient: isPatient,
      doctorUid: doctorUid,
    );
  }

  // ============================================================
  // ⭐ NEW — PATIENT META USE CASES
  // ============================================================

  /// ➕ Add meta record
  Future<Either<AppError, SuccessModel>> addPatientReservationMeta(
    ReservationModel meta,
    String patientKey,
  ) {
    return _repository.addPatientReservationMetaDomain(meta, patientKey);
  }

  /// 🔍 Get meta list
  Future<Either<AppError, List<ReservationModel>>> getPatientReservationsMeta(
    String patientKey,
  ) {
    return _repository.getPatientReservationsMetaDomain(patientKey);
  }

  /// 🔄 NEW — Update patient reservation meta
  Future<Either<AppError, SuccessModel>> updatePatientReservation(
      ReservationModel data,
    String key,
  ) {
    return _repository.updatePatientReservationDomain(data, key);
  }
}
