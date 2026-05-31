import '../../../../../index/index_main.dart';

/// Tap to navigate to PharmacyDetailView — all management is done there.
class PharmacyCard extends StatelessWidget {
  final LocalUser? pharmacy; // primary account
  final List<LocalUser> staffList; // all accounts (including primary)
  final PharmacyViewModel controller;

  const PharmacyCard({
    Key? key,
    required this.pharmacy,
    required this.staffList,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pharmacyId = pharmacy?.pharmacyId ?? pharmacy?.uid ?? '';
    final staffCount = staffList.where((s) => s.uid != pharmacy?.uid).length;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Get.to(
          () => PharmacyDetailView(
            pharmacyId: pharmacyId,
            pharmacyName: pharmacy?.name,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 14.w),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderNeutralPrimary, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.local_pharmacy_outlined,
                  color: AppColors.primary, size: 20),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pharmacy?.name ?? "",
                    style: context.typography.mdBold,
                  ),
                  if (pharmacy?.phone != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      pharmacy!.phone!,
                      style: context.typography.smRegular.copyWith(
                        color: AppColors.textSecondaryParagraph,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (staffCount > 0) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.people_outline, size: 14, color: AppColors.primary),
                    SizedBox(width: 4.w),
                    Text(
                      "$staffCount",
                      style: context.typography.smMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
            ],
            const Icon(Icons.chevron_right, color: AppColors.textSecondaryParagraph, size: 20),
          ],
        ),
      ),
    );
  }
}
