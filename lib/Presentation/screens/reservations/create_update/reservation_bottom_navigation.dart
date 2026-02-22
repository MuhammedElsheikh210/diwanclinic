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
    final bool isValid = controller.validateCurrentStep();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          /// Previous Button
          Expanded(
            child: OutlinedButton(
              onPressed: controller.currentStep > 1
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
              onPressed: isValid
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
                disabledBackgroundColor:
                AppColors.primary.withOpacity(.3),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                isLastStep ? "حفظ الحجز" : "التالي",
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
