import '../../../../../../../index/index_main.dart';

class ReservationDetailsSection extends StatelessWidget {
  final ReservationModel reservation;

  const ReservationDetailsSection({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    final value = DatesUtilis.convertTimestamp(reservation.createdAt ?? 0);
    return Row(
      children: [
        Expanded(
          child: ReservationListTileWidget(
            icon: IconsConstants.reserve_type,
            title: "نوع الحجز",
            body: reservation.reservationType ?? "",
          ),
        ),

        Expanded(child: _buildDatesSection(context, reservation)),
        // Expanded(
        //   child: ReservationListTileWidget(
        //     icon: IconsConstants.calendar,
        //     title: " ${reservation.appointmentDateTime}تاريخ الحجز",
        //     body: DatesUtilis.convertTimestamp(reservation.createAt ?? 0),
        //   ),
        // ),
      ],
    );
  }
}

Widget _buildDatesSection(BuildContext context, ReservationModel reservation) {
  final bookingDate = DatesUtilis.convertTimestamp<String>(
    reservation.createdAt ?? 0,
  );

  final appointmentDate = reservation.appointmentDateTime ?? "";

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    margin: const EdgeInsets.only(left: 5),
    decoration: BoxDecoration(
      color: AppColors.grayLight.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 Booking date
        _dateRow(
          icon: Icons.edit_calendar_rounded,
          label: "تاريخ الحجز",
          value: bookingDate,
          context: context,
        ),

        const SizedBox(height: 8),

        // 🔹 Appointment date
        _dateRow(
          icon: Icons.access_time_rounded,
          label: "موعد الكشف",
          value: appointmentDate,
          context: context,
          highlight: true,
        ),
      ],
    ),
  );
}

Widget _dateRow({
  required IconData icon,
  required String label,
  required String value,
  required BuildContext context,
  bool highlight = false,
}) {
  return Row(
    children: [
      Icon(
        icon,
        size: 18,
        color: highlight ? AppColors.successForeground : AppColors.grayMedium,
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          label,
          style: context.typography.smRegular.copyWith(
            color: AppColors.textSecondaryParagraph,
          ),
        ),
      ),
      Text(
        value,
        style: context.typography.mdBold.copyWith(
          color: highlight
              ? AppColors.successForeground
              : AppColors.background_black,
        ),
      ),
    ],
  );
}
