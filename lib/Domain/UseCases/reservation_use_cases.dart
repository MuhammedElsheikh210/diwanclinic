import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class ReservationUseCases {
  final ReservationRepository _repository;

  ReservationUseCases(this._repository);

  // ============================================================
  // 🔥 START REALTIME SYNC (Firebase → SQLite)
  // ============================================================

  Future<void> startListening({
    required String doctorKey,
  }) {
    return _repository.startListening(doctorKey: doctorKey);
  }

  Future<void> stopListening() {
    return _repository.stopListening();
  }

  // ============================================================
  // 🔥 REALTIME STREAMS (Expose to Service / ViewModel)
  // ============================================================

  Stream<ReservationModel> get onAdded => _repository.onAdded;

  Stream<ReservationModel> get onChanged => _repository.onChanged;

  Stream<String> get onRemoved => _repository.onRemoved;

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
  // ⭐ PATIENT META
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
  // 🛑 STOP REALTIME SYNC
  // ============================================================

  Future<void> dispose() {
    return _repository.dispose();
  }
}