import '../../../../../index/index_main.dart';

class MedicalCenterCard extends StatelessWidget {
  final MedicalCenterModel center;

  const MedicalCenterCard({super.key, required this.center});

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.background_black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28.r,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            backgroundImage: center.logo != null
                ? NetworkImage(center.logo!)
                : null,
            child: center.logo == null
                ? Icon(Icons.local_hospital,
                color: AppColors.primary, size: 26.sp)
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(center.name ?? "بدون اسم",
                    style: typography.mdBold.copyWith(
                        color: AppColors.textDisplay)),
                SizedBox(height: 4.h),
                Text(center.address ?? "بدون عنوان",
                    style: typography.smRegular.copyWith(
                        color: AppColors.textSecondaryParagraph)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded,
              size: 18.sp, color: AppColors.textSecondaryParagraph),
        ],
      ),
    );
  }
}