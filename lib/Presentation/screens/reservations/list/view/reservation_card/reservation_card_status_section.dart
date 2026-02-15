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
    return Column(
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
    );
  }
}
