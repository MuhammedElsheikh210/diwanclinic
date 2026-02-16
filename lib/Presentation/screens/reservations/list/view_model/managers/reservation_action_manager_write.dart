import '../../../../../../../index/index_main.dart';

class ReservationActionManager {
  Future<void> addReservation(
    ReservationModel reservation, {
    bool localOnly = false,
  }) async {
    await ReservationService().addReservationData(
      date: reservation.appointmentDateTime ?? "",
      reservation: reservation,
      localOnly: localOnly,
      voidCallBack: (_) {
        Loader.dismiss();
      },
    );
  }

  Future<void> updateReservation(
    ReservationModel reservation, {
    required bool isSyncing,
    bool localOnly = false,
  }) async {
    Loader.dismiss();

    await ReservationService().updateReservationData(
      date: reservation.appointmentDateTime ?? "",
      reservation: reservation,
      localOnly: localOnly,
      voidCallBack: (_) async {
        await updatePatientReservation(reservation);

        if (reservation.status == ReservationStatus.approved.value) {
          await NotificationCleanupService.removeReservationNotifications(
            reservationKey: reservation.key!,
          );
        }
      },
    );
  }

  Future<void> deleteReservation(ReservationModel reservation) async {
    await ReservationService().deleteReservationData(
      date: reservation.appointmentDateTime ?? "",
      reservationKey: reservation.key ?? "",
      voidCallBack: (_) {},
    );
  }

  Future<void> updatePatientReservation(ReservationModel reservation) async {
    await ReservationService().updatePatientReservationData(
      key: reservation.key ?? "",
      data: reservation,

      voidCallBack: (_) {},
    );
  }
}
