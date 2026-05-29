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
    // Update doctor node
    await ReservationService().updateReservationData(
      reservation: reservation,
      voidCallBack: (_) {},
    );

    // Mirror update to patient node so the patient sees real-time changes
    if (reservation.patientUid?.isNotEmpty == true) {
      await PatientReservationService().updateReservationData(
        reservation: reservation,
        voidCallBack: (_) {},
      );
    }
  }

  Future<void> deleteReservation(ReservationModel reservation) async {
    await ReservationService().deleteReservationData(
      reservationKey: reservation.key ?? "",
      voidCallBack: (_) {},
    );
  }
}
