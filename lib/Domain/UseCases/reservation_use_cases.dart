import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class ReservationUseCases {
  final ReservationRepository _repository;

  ReservationUseCases(this._repository);

  // ============================================================
  // 🔥 START REALTIME LISTENING (Reservations Only)
  // ============================================================

  void startListening({
    required String doctorKey,
    required String date,
    required Function(ReservationModel model) onChanged,
    required Function(String key) onRemoved,
  }) {
    _repository.startListening(
      doctorKey: doctorKey,
      date: date,
      onChanged: onChanged,
      onRemoved: onRemoved,
    );
  }

  // ============================================================
  // 🔹 RESERVATIONS (Offline First)
  // ============================================================

  Future<Either<AppError, Unit>> addReservation(
      ReservationModel reservation,
      ) {
    return _repository.addReservationDomain(reservation);
  }

  Future<Either<AppError, Unit>> updateReservation(
      ReservationModel reservation,
      ) {
    return _repository.updateReservationDomain(reservation);
  }

  Future<Either<AppError, Unit>> deleteReservation(
      String key,
      ) {
    return _repository.deleteReservationDomain(key);
  }

  Future<Either<AppError, List<ReservationModel?>>> getReservations(
      SQLiteQueryParams query,
      ) {
    return _repository.getReservationsDomain(query);
  }

  // ============================================================
  // ⭐ PATIENT META (Remote Direct)
  // ============================================================

  Future<Either<AppError, SuccessModel>> addPatientReservationMeta(
      ReservationModel meta,
      String patientKey,
      ) {
    return _repository.addPatientReservationMetaDomain(
      meta,
      patientKey,
    );
  }

  Future<Either<AppError, SuccessModel>> updatePatientReservation(
      ReservationModel meta,
      String key,
      ) {
    return _repository.updatePatientReservationDomain(
      meta,
      key,
    );
  }

  Future<Either<AppError, List<ReservationModel>>>
  getPatientReservationsMeta(
      String patientKey,
      ) {
    return _repository.getPatientReservationsMetaDomain(
      patientKey,
    );
  }

  // ============================================================
  // 🔥 STOP LISTENING
  // ============================================================

  void dispose() {
    _repository.dispose();
  }
}