import '../../../../../index/index_main.dart';

class UploadPrescriptionCard extends StatelessWidget {
  final VoidCallback onTap;

  const UploadPrescriptionCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderNeutralPrimary, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // 📄 Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.upload_file,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // Texts
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "رفع الروشتة",
                  style: context.typography.mdBold.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  "قم باختيار أو تحميل الروشتة الحالية",
                  style: context.typography.smRegular.copyWith(
                    color: AppColors.textSecondaryParagraph,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Arrow
            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: AppColors.textSecondaryParagraph,
            ),
          ],
        ),
      ),
    );
  }
}
