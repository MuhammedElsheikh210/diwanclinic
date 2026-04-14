import 'package:diwanclinic/Global/Enums/reservation_status_new.dart';
import 'package:diwanclinic/index/index_main.dart';

class GridReservationCard extends StatelessWidget {
  final ReservationModel reservation;
  final ReservationViewModel controller;

  const GridReservationCard({
    super.key,
    required this.reservation,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final ahead = (reservation.orderReserved ?? 0) - 1;

    final bool isCompleted =
        reservation.status == ReservationStatus.completed.value;

    final bool isCancelled =
        reservation.status == ReservationStatus.cancelledByAssistant.value ||
        reservation.status == ReservationStatus.cancelledByDoctor.value ||
        reservation.status == ReservationStatus.cancelledByUser.value;

    final Color statusColor = _statusColor(reservation.status);
    final String statusLabel = isCompleted
        ? "تم الكشف"
        : isCancelled
        ? "ملغي"
        : "";

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderNeutralPrimary.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -------------------------
          // LEFT SIDE (NAME + STATUS)
          // -------------------------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reservation.patientName ?? "بدون اسم",
                  style: context.typography.mdBold.copyWith(
                    color: AppColors.background_black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                if (isCompleted || isCancelled)
                  Text(
                    statusLabel,
                    style: context.typography.smMedium.copyWith(
                      color: AppColors.white,
                    ),
                  ),
              ],
            ),
          ),

          // -------------------------
          // RIGHT SIDE (QUEUE INFO)
          // -------------------------
          if (!isCompleted && !isCancelled)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  ahead <= 0 ? "دورك الآن" : "قدّامك: $ahead",
                  style: context.typography.smRegular.copyWith(
                    color: AppColors.textSecondaryParagraph,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "رقم: ${reservation.orderNum ?? "-"}",
                  style: context.typography.smRegular.copyWith(
                    color: AppColors.textSecondaryParagraph,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // -------------------------
  // STATUS COLOR HELPER
  // -------------------------
  Color _statusColor(String? status) {
    if (status == ReservationNewStatus.completed.value) {
      return AppColors.primary;
    }

    if (status == ReservationStatus.cancelledByAssistant.value ||
        status == ReservationStatus.cancelledByDoctor.value ||
        status == ReservationStatus.cancelledByUser.value) {
      return AppColors.errorForeground;
    }

    return AppColors.white;
  }
}
