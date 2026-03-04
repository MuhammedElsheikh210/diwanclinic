import '../../../../../../index/index_main.dart';

class ReservationActionManager {
  Future<void> addReservation(ReservationModel reservation) async {
    await ReservationService().addReservationData(
      reservation: reservation,
      voidCallBack: (_) {
        Loader.dismiss();
      },
    );
  }

  Future<void> updateReservation(ReservationModel reservation) async {
    await ReservationService().updateReservationData(
      reservation: reservation,
      voidCallBack: (_) {},
    );
  }

  Future<void> deleteReservation(ReservationModel reservation) async {
    await ReservationService().deleteReservationData(
      reservationKey: reservation.key ?? "",
      voidCallBack: (_) {},
    );
  }
}
