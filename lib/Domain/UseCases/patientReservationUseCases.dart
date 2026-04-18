import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class PatientReservationUseCases {
  final PatientReservationRepository _repository;

  PatientReservationUseCases(this._repository);

  // ============================================================
  // 🔥 START REALTIME
  // ============================================================

  Future<void> startListening({required String patientUid}) {
    return _repository.startListening(patientUid: patientUid);
  }

  Future<void> stopListening() {
    return _repository.stopListening();
  }

  // ============================================================
  // 🔥 REALTIME STREAMS
  // ============================================================

  Stream<ReservationModel> get onAdded => _repository.onAdded;

  Stream<ReservationModel> get onChanged => _repository.onChanged;

  Stream<String> get onRemoved => _repository.onRemoved;

  // ============================================================
  // ☁️ REMOTE OPERATIONS (Realtime Only)
  // ============================================================

  Future<Either<AppError, Unit>> addReservation(ReservationModel reservation) {
    return _repository.addReservationDomain(reservation);
  }

  Future<Either<AppError, Unit>> updateReservation(
    ReservationModel reservation,
  ) {
    return _repository.updateReservationDomain(reservation);
  }

  Future<Either<AppError, Unit>> deleteReservation(
    ReservationModel reservation,
  ) {
    return _repository.deleteReservationDomain(reservation);
  }

  // ============================================================
  // 🛑 DISPOSE
  // ============================================================

  Future<void> dispose() {
    return _repository.dispose();
  }
}
