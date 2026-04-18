import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

abstract class PatientReservationRepository {
  // ============================================================
  // 🔥 REALTIME CONTROL
  // ============================================================

  Future<void> startListening({required String patientUid});

  Future<void> stopListening();

  Future<void> dispose();

  // ============================================================
  // 🔥 REALTIME STREAMS
  // ============================================================

  Stream<ReservationModel> get onAdded;

  Stream<ReservationModel> get onChanged;

  Stream<String> get onRemoved;

  // ============================================================
  // ☁️ REMOTE OPERATIONS (Realtime Only)
  // ============================================================

  Future<Either<AppError, Unit>> addReservationDomain(
      ReservationModel model,
      );

  Future<Either<AppError, Unit>> updateReservationDomain(
      ReservationModel model,
      );

  Future<Either<AppError, Unit>> deleteReservationDomain(
      ReservationModel model,
      );
}