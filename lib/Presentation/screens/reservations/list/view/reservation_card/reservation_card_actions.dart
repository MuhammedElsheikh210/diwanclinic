import 'package:diwanclinic/Presentation/screens/pharmacy_orders/list/bottom_sheets/cancel_with_reason_dialog.dart';
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

    // Chat button — only when patient has the app
    if (reservation.patientUid?.isNotEmpty == true) {
      buttons.add(_chatButton(context));
      buttons.add(_space);
    }

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

  // CHAT BUTTON
  Widget _chatButton(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        final session = Get.find<UserSession>();
        final user = session.user?.user as AssistantUser?;
        final doctorKey = user?.doctorKey ?? "";
        final assistantName = session.user?.name ?? "المساعدة";

        Get.to(
          () => AssistantChatDetailView(
            assistantId: doctorKey,
            assistantName: assistantName,
            patientId: reservation.patientUid!,
            patientName: reservation.patientName ?? "مريض",
            isAssistantSide: true,
            receiverFcmToken: reservation.patientFcm,
          ),
          binding: Binding(),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        ),
        child: const Icon(
          Icons.chat_bubble_outline_rounded,
          color: AppColors.primary,
          size: 20,
        ),
      ),
    );
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
                () => _showCancelDialog(context), // ✅ هنا التعديل

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

      case ReservationNewStatus.missed:
        return [
          _space,
          _actionButton(
            context,
            "رجع",
            Colors.teal,
            () => controller.returnMissedPatient(reservation),
          ),
        ];

      default:
        return [];
    }


  }

  // ------------------------------------------------------------------
  // ❌ CANCEL DIALOG (🔥 الجديد)
  // ------------------------------------------------------------------
  void _showCancelDialog(BuildContext context) {
    CancelWithReasonDialog.show(
      context: context,
      title: "تأكيد إلغاء الحجز",
      confirmText: "تأكيد الإلغاء",
      confirmColor: AppColors.errorForeground,
      reasons: const [
        "المريض لم يحضر",
        "تم الحجز بالخطأ",
        "تأخر الموعد",
        "سبب آخر",
      ],
      onConfirm: (reason) {
        // 👇 تقدر تبعت السبب هنا لو عايز
        controller.changeReservationStatus(
          reservation: reservation,
          newStatus: ReservationStatus.cancelledByAssistant,
          cancelReason: reason, // 🔥 لو عندك في الميثود
        );

      },
    );
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
