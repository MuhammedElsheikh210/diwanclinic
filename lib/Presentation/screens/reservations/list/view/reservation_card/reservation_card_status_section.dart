import '../../../../../../index/index_main.dart';

class ReservationCardStatusSection extends StatelessWidget {
  final ReservationModel reservation;
  final ReservationNewStatus status;

  const ReservationCardStatusSection({
    super.key,
    required this.reservation,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /// 🔹 Left side → Type + Status
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              reservation.reservationType ?? "",
              style: context.typography.lgBold.copyWith(
                color: AppColors.background_black,
              ),
            ),
            const SizedBox(height: 5),
            StatusBadge(
              status: reservation.status ?? "",
              label: status.label,
              dateTimeStamp: 0,
              color: status.color,
            ),
          ],
        ),

        /// 🔹 Right side → Edit Button
        InkWell(
          onTap: () async {
            final controller = Get.find<ReservationViewModel>();

            final trueTotal = await controller.getTotalTodayReservations();

            Get.to(
              () => CreateReservationView(
                reservation: reservation,
                list_reservations: controller.listReservations ?? [],
                dailly_date: controller.appointmentDate ?? "",
                clinic_key: controller.selectedClinic?.key,
                shift_key: controller.selectedShift?.key,
                selected_clinic: controller.selectedClinic ?? ClinicModel(),
                doctor_key: controller.selectedDoctor?.uid,
              ),
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.edit, size: 16, color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
