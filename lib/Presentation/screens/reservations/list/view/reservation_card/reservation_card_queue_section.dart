import '../../../../../../index/index_main.dart';

class ReservationCardQueueSection extends StatelessWidget {
  final ReservationModel reservation;
  final ReservationNewStatus status;
  final int ahead;

  const ReservationCardQueueSection({
    super.key,
    required this.reservation,
    required this.status,
    required this.ahead,
  });

  @override
  Widget build(BuildContext context) {
    if (reservation.status == ReservationStatus.completed.value ||
        reservation.status == ReservationStatus.inProgress.value) {
      return const SizedBox();
    }

    if (ahead < 0) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        if (ahead == 0)
          Text(
            "دورك دلوقتي",
            style: context.typography.mdMedium.copyWith(
              color: AppColors.background_black,
            ),
          )
        else
          Row(
            children: [
              AppText(
                text: " : قدامك",
                textStyle: context.typography.mdMedium.copyWith(
                  color: ColorMappingImpl().textSecondaryParagraph,
                ),
              ),
              const SizedBox(width: 5),
              AppText(
                text: "$ahead",
                textStyle: context.typography.lgBold.copyWith(
                  color: ColorMappingImpl().textDisplay,
                ),
              ),
            ],
          ),
        const SizedBox(height: 6),
        Row(
          children: [
            AppText(
              text: " :رقم الحجز",
              textStyle: context.typography.mdMedium.copyWith(
                color: ColorMappingImpl().textSecondaryParagraph,
              ),
            ),
            const SizedBox(width: 5),
            AppText(
              text: "${reservation.order_num ?? '-'}",
              textStyle: context.typography.lgBold.copyWith(
                color: ColorMappingImpl().textDisplay,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
