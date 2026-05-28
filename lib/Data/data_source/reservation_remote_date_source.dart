import '../../index/index_main.dart';

abstract class ReservationRemoteDataSource {
  Future<void> createReservation(ReservationModel model);

  Future<void> updateReservation(ReservationModel model);

  Future<void> deleteReservation(ReservationModel model);

  // ============================================================
  // 🎧 REALTIME CONTROL
  // ============================================================

  /// Start realtime listening to doctor's reservations for a specific date
  Future<void> startListening({required String doctorKey, required String date});

  /// Stop all active listeners
  Future<void> stopListening();

  // ============================================================
  // 🔥 REALTIME STREAMS
  // ============================================================

  /// Emits when a reservation is added
  Stream<ReservationModel> get onAdded;

  /// Emits when a reservation is updated
  Stream<ReservationModel> get onChanged;

  /// Emits when a reservation is deleted
  Stream<String> get onRemoved;

  // ============================================================
  // 📥 ONE-TIME FETCH (PATIENT USE)
  // ============================================================

  /// Fetch reservations once for a specific doctor & date
  Future<List<ReservationModel>> fetchReservationsOnce({
    required String doctorKey,
    required String date, // format: yyyy-MM-dd
  });
}