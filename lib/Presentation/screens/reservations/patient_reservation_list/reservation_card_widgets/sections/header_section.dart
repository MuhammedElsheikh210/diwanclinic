import 'package:diwanclinic/Global/Enums/reservation_status_new.dart';

import '../../../../../../../index/index_main.dart';

class HeaderSection extends StatelessWidget {
  final ReservationModel reservation;
  final ReservationStatus status;
  final ReservationPatientViewModel controller;

  const HeaderSection({
    super.key,
    required this.reservation,
    required this.status,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final aheadCount = controller.calculateAheadCount(reservation);

    return Container(
      decoration: BoxDecoration(
        color: ColorMappingImpl().background_neutral_100,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
        boxShadow: AppShadow.deals_cart_top_shadow,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          (reservation.status != ReservationStatus.completed.value &&
              reservation.status !=
                  ReservationStatus.cancelledByAssistant.value &&
              reservation.status !=
                  ReservationStatus.cancelledByUser.value)
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: "رقم الحجز: ${reservation.orderNum ?? '-'}",
                textStyle: context.typography.mdMedium.copyWith(
                  color:
                  ColorMappingImpl().textSecondaryParagraph,
                ),
              ),
              const SizedBox(height: 4),
              if (aheadCount > 0)
                AppText(
                  text: "قدامك $aheadCount حجز",
                  textStyle:
                  context.typography.smMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else
                AppText(
                  text: "دورك الآن 🎉",
                  textStyle:
                  context.typography.smMedium.copyWith(
                    color:
                    AppColors.successForeground,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          )
              : const SizedBox(),

          StatusBadge(
            status: reservation.status ?? "",
            label: status.label,
            dateTimeStamp: 0,
            color: status.color,
          ),
        ],
      ),
    );
  }
}
