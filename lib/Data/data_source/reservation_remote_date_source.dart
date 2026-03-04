import '../../index/index_main.dart';

abstract class ReservationRemoteDataSource {
  Future<void> createReservation(ReservationModel model);

  Future<void> updateReservation(ReservationModel model);

  Future<void> deleteReservation(ReservationModel model);

  Future<void> listenToReservations({
    required String doctorKey,
    required String date,
    required Function(ReservationModel model) onAdded,
    required Function(ReservationModel model) onChanged,
    required Function(String key) onRemoved,
  });

  Future<void> stopListening();
}
