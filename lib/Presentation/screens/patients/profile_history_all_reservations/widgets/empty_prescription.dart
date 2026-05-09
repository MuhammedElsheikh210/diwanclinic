import '../../../../../index/index_main.dart';

class EmptyPrescription extends StatelessWidget {
  const EmptyPrescription({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: AppColors.background_neutral_100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.borderNeutralPrimary,
        ),
      ),

      child: Row(
        children: [
          const Icon(
            Icons.medical_information_outlined,
            color:
            AppColors.textSecondaryParagraph,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              "لا توجد روشتة مرفقة لهذا الكشف",
              style:
              context.typography.smRegular.copyWith(
                color:
                AppColors.textSecondaryParagraph,
              ),
            ),
          ),
        ],
      ),
    );
  }
}