import '../../../../index/index_main.dart';

class ReservationBottomNavigation extends StatelessWidget {
  final CreateReservationViewModel controller;
  final VoidCallback onSave;

  const ReservationBottomNavigation({
    super.key,
    required this.controller,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLastStep = controller.currentStep == 3;

    /// 🔥 مهم: ضيف شرط اليوم مغلق
    final bool isValid =
        controller.validateCurrentStep() && !controller.isDayClosed;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          /// Previous Button
          Expanded(
            child: OutlinedButton(
              onPressed:
                  controller.currentStep > 1
                      ? controller.previousStep
                      : () => Get.back(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: AppColors.primary.withOpacity(.4)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                "السابق",
                style: context.typography.mdMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          /// Next / Save Button
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed:
                  isValid
                      ? () {
                        if (isLastStep) {
                          onSave();
                        } else {
                          controller.nextStep();
                        }
                      }
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,

                /// 🔥 شكل أوضح للـ disabled
                disabledBackgroundColor: AppColors.primary.withOpacity(.2),

                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),

              /// 🔥 تغيير النص حسب الحالة
              child: Text(
                controller.isDayClosed
                    ? "اليوم مغلق"
                    : isLastStep
                    ? "حفظ الحجز"
                    : "التالي",
                style: context.typography.mdMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
