import '../../../../../../../index/index_main.dart';
import '../card_details.dart';

class ButtonsSection extends StatelessWidget {
  final ReservationModel reservation;
  final ReservationPatientViewModel controller;
  final ReservationStatus status;
  final int index;
  final bool? show_details;

  const ButtonsSection({
    super.key,
    required this.reservation,
    required this.controller,
    required this.status,
    required this.index,
    this.show_details,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> buttons = [];

    if (show_details == true) {
      buttons.add(
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: PrimaryTextButton(
              onTap: () => Get.to(
                () => ReservationPatientDetailsScreen(
                  reservation: reservation,
                  controller: controller,
                  index: index,
                ),
              ),
              appButtonSize: AppButtonSize.large,
              customBackgroundColor: ColorMappingImpl().white,
              customBorder: BorderSide(
                color: ColorMappingImpl().borderNeutralPrimary,
              ),
              label: AppText(
                text: "تفاصيل",
                textStyle: context.typography.smMedium.copyWith(
                  color: ColorMappingImpl().textDefault,
                ),
              ),
            ),
          ),
        ),
      );
    }
    //
    // // 🔴 إلغاء
    // if (![
    //   ReservationStatus.completed,
    //   ReservationStatus.cancelledByUser,
    //   ReservationStatus.cancelledByAssistant,
    //   ReservationStatus.cancelledByDoctor,
    // ].contains(status)) {
    //   buttons.add(
    //     Expanded(
    //       child: PrimaryTextButton(
    //         onTap: () async {
    //           NotificationHandler().sendStatusNotification(
    //             newStatus: ReservationStatus.cancelledByUser,
    //             reservation: reservation,
    //             toToken: reservation.fcmToken_assist ?? "",
    //           );
    //         },
    //         appButtonSize: AppButtonSize.large,
    //         customBackgroundColor: AppColors.errorForeground,
    //         label: AppText(
    //           text: "إلغاء",
    //           textStyle: context.typography.mdMedium.copyWith(
    //             color: Colors.white,
    //           ),
    //         ),
    //       ),
    //     ),
    //   );
    // }

    // ⭐ تقييم الدكتور
    if (status == ReservationStatus.completed &&
        reservation.hasFeedback != true) {
      buttons.add(
        Expanded(
          child: PrimaryTextButton(
            onTap: () => _showFeedbackBottomSheet(context),
            appButtonSize: AppButtonSize.large,
            customBackgroundColor: AppColors.primary,
            label: AppText(
              text: "تقييم الدكتور",
              textStyle: context.typography.mdMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(children: buttons),
    );
  }

  // ---------------------------------------------------------------------------
  // ⭐ show feedback sheet
  // ---------------------------------------------------------------------------
  void _showFeedbackBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) =>
          FeedbackSheet(reservation: reservation, controller: controller),
    );
  }
}
