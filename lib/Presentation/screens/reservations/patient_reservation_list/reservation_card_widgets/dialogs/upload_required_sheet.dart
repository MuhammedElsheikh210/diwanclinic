import 'package:flutter/material.dart';
import 'package:diwanclinic/Presentation/screens/reservations/patient_reservation_list/patient_reservation_view_model.dart';
import '../../../../../../../../index/index_main.dart';

class UploadRequiredSheet extends StatelessWidget {
  final ReservationModel reservation;
  final ReservationPatientViewModel controller;

  const UploadRequiredSheet({
    super.key,
    required this.reservation,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 45,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 18),

            Text(
              "تنبيه هام",
              style: context.typography.xlBold.copyWith(
                color: AppColors.textDisplay,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              "يجب عليك أولاً رفع صورة الروشتة بعد انتهاء الكشف.\n"
                  "ستحصل على خصم يصل إلى 10%، وسيتم توصيل العلاج إلى باب منزلك 🚚💊",
              textAlign: TextAlign.center,
              style: context.typography.mdRegular.copyWith(
                color: AppColors.textSecondaryParagraph,
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: PrimaryTextButton(
                appButtonSize: AppButtonSize.xxLarge,
                customBackgroundColor: AppColors.primary,
                label: AppText(
                  text: "رفع الروشتة",
                  textStyle: context.typography.mdBold.copyWith(
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  controller.openPrescriptionBottomSheet(
                    context: context,
                    reservation: reservation,
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: PrimaryTextButton(
                appButtonSize: AppButtonSize.large,
                customBackgroundColor: AppColors.background_neutral_100,
                label: AppText(
                  text: "إغلاق",
                  textStyle: context.typography.mdMedium.copyWith(
                    color: AppColors.textDefault,
                  ),
                ),
                onTap: () => Navigator.pop(context),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
