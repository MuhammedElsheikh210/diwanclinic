import 'package:diwanclinic/Presentation/screens/reservations/list/view/reservation_card/bottom_sheets/reservation_cancel_reason_sheet.dart';

import '../../../../../../index/index_main.dart';

class ReservationCardActions extends StatelessWidget {
  final ReservationModel reservation;
  final ReservationViewModel controller;

  const ReservationCardActions({
    super.key,
    required this.reservation,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final status = ReservationStatusNewExt.fromValue(reservation.status ?? "");

    final List<Widget> buttons = [];

    // Always add Details
    buttons.add(_detailsButton(context));

    // Add Order Button if completed and not ordered
    if (reservation.isOrdered != true &&
        status == ReservationNewStatus.completed) {
      buttons.add(_space);
      buttons.add(_orderButton(context));
    }

    // Add status buttons dynamically
    buttons.addAll(_statusButtons(context, status));

    return Row(children: buttons);
  }

  // DETAILS BUTTON
  Widget _detailsButton(BuildContext context) {
    return Expanded(
      child: PrimaryTextButton(
        onTap: () {
          Get.to(
            () => ReservationAssistantDetailsView(
              reservation: reservation,
              controller: controller,
              index: 0,
            ),
            binding: Binding(),
          );
        },
        appButtonSize: AppButtonSize.large,
        customBackgroundColor: ColorMappingImpl().white,
        customBorder: BorderSide(
          color: ColorMappingImpl().borderNeutralPrimary,
        ),
        label: AppText(
          text: "تفاصيل",
          textStyle: context.typography.mdMedium.copyWith(
            color: ColorMappingImpl().textDefault,
          ),
        ),
      ),
    );
  }

  // ORDER BUTTON
  Widget _orderButton(BuildContext context) {
    return Expanded(
      child: PrimaryTextButton(
        onTap: () {
          controller.handleMakeOrder(reservation);
        },
        appButtonSize: AppButtonSize.large,
        customBackgroundColor: ColorMappingImpl().white,
        customBorder: BorderSide(
          color: ColorMappingImpl().borderNeutralPrimary,
        ),
        label: AppText(
          text: "طلب الروشتة",
          textStyle: context.typography.mdMedium.copyWith(
            color: ColorMappingImpl().textDefault,
          ),
        ),
      ),
    );
  }

  List<Widget> _statusButtons(
    BuildContext context,
    ReservationNewStatus status,
  ) {
    switch (status) {
      case ReservationNewStatus.pending:
        return [
          _space,
          _actionButton(
            context,
            "موافقة",
            AppColors.successForeground,
            () => controller.changeReservationStatus(
              reservation: reservation,
              newStatus: ReservationStatus.approved,
            ),
          ),
          _space,
          _actionButton(
            context,
            "إلغاء",
            AppColors.errorForeground,
            () => controller.changeReservationStatus(
              reservation: reservation,
              newStatus: ReservationStatus.cancelledByAssistant,
            ),
          ),
        ];

      case ReservationNewStatus.approved:
        return [
          _space,
          _actionButton(
            context,
            "إبدأ الكشف",
            AppColors.primary,
            () => controller.changeReservationStatus(
              reservation: reservation,
              newStatus: ReservationStatus.inProgress,
            ),
          ),
          _space,

          _actionButton(context, "إلغاء", AppColors.errorForeground, () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: AppColors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              builder: (_) => ReservationCancelReasonSheet(
                reservation: reservation,
                controller: controller,
              ),
            );
          }),
        ];

      case ReservationNewStatus.inProgress:
        return [
          _space,
          _actionButton(
            context,
            "تم الكشف",
            AppColors.background_black,
            () => controller.changeReservationStatus(
              reservation: reservation,
              newStatus: ReservationStatus.completed,
            ),
          ),
        ];

      default:
        return [];
    }
  }

  Widget _actionButton(
    BuildContext context,
    String text,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: PrimaryTextButton(
        onTap: onTap,
        appButtonSize: AppButtonSize.large,
        customBackgroundColor: color,
        label: AppText(
          text: text,
          textStyle: context.typography.mdMedium.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  static const _space = SizedBox(width: 8);
}
