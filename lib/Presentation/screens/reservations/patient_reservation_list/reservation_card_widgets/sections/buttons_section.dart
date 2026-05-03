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
              onTap:
                  () => Get.to(
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

    // 🔴 إلغاء
    if (![
      ReservationStatus.completed,
      ReservationStatus.cancelledByUser,
      ReservationStatus.cancelledByAssistant,
      ReservationStatus.cancelledByDoctor,
    ].contains(status)) {
      buttons.add(
        Expanded(
          child: PrimaryTextButton(
            onTap: () async {
              final confirmed = await _showCancelDialog(context);

              if (confirmed != true) return;

              await _updateStatus(ReservationStatus.cancelledByUser);

            },
            appButtonSize: AppButtonSize.large,
            customBackgroundColor: AppColors.errorForeground,
            label: AppText(
              text: "إلغاء",
              textStyle: context.typography.mdMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }

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
  // ❗ Confirmation Dialog
  // ---------------------------------------------------------------------------
  Future<bool?> _showCancelDialog(BuildContext context) {
    return Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 50.sp,
                color: AppColors.errorForeground,
              ),

              SizedBox(height: 10.h),

              Text("تأكيد الإلغاء", style: context.typography.lgBold),

              SizedBox(height: 10.h),

              Text(
                "هل أنت متأكد أنك تريد إلغاء هذا الحجز؟",
                textAlign: TextAlign.center,
                style: context.typography.mdMedium.copyWith(height: 1.5),
              ),

              SizedBox(height: 20.h),

              Row(
                children: [
                  /// ❌ إلغاء
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                      child: Text(
                        "رجوع",
                        style: context.typography.mdMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 10.w),

                  /// ✅ تأكيد
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.errorForeground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                      child: Text(
                        "تأكيد",
                        style: context.typography.mdMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
      builder:
          (_) =>
              FeedbackSheet(reservation: reservation, controller: controller),
    );
  }

  // ---------------------------------------------------------------------------
  // 🔄 update status
  // ---------------------------------------------------------------------------
  Future<void> _updateStatus(ReservationStatus newStatus) async {
    if (newStatus == ReservationStatus.completed) {
      try {
        final phone = reservation.patientPhone ?? "";
        if (phone.isNotEmpty) {
          final formatted = WhatsAppManager.formatNumber(phone);

          final patient = reservation.patientName ?? "المريض";
          final doctor = reservation.doctorName ?? "العيادة";

          const android = Strings.url_android;
          const ios = Strings.url_ios;

          final message = """
من عيادة د. $doctor 👨‍⚕️

الكشف خلص يا $patient 🌿  
تقدر تطلب العلاج لحد بيتك مع خصم 5٪ - 10٪

سجل دخول على تطبيق لينك باستخدام رقمك:  
$phone

📱 أندرويد: $android  
🍎 آيفون: $ios
""";

          if (controller.selectedClinic?.sendWhatsapp == 1) {
            await WhatsAppManager.sendMessage(to: formatted, body: message);
          }
        }
      } catch (_) {}
    }

    reservation.status = newStatus.value;
    controller.updateReservation(reservation);
    Loader.showSuccess("تم تحديث الحالة إلى ${newStatus.label}");
  }
}
