import '../../../../../../index/index_main.dart';

Future<void> openOrderConfirmationSheet(
  BuildContext context,
  ReservationViewModel controller,
  ReservationModel reservation,
) async {
  if (reservation.patientKey == null) {
    Loader.showError("بيانات العميل غير متوفرة");
    return;
  }

  Loader.show();

  final user = await controller.queryManager.getPatientByKey(
    reservation.patientKey!,
  );

  Loader.dismiss();

  if (user == null) {
    Loader.showError("لم يتم العثور على بيانات العميل");
    return;
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => OrderConfirmationSheet(
      reservation: reservation,
      user: user,
      onConfirmed: (updatedReservation) {
        controller.actionManager.updateReservation(
          reservation,
        );
      },
    ),
  );
}
