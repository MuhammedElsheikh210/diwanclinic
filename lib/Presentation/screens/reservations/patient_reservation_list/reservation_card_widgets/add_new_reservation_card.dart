import '../../../../../../index/index_main.dart';

class AddNewReservationCard extends StatelessWidget {
  final VoidCallback onTap;

  const AddNewReservationCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,
      child: Container(
        width: ScreenUtil().screenWidth - 50.w,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: ColorMappingImpl().borderNeutralPrimary.withOpacity(0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // دائرة بها أيقونة +
            Container(
              width: 65.w,
              height: 65.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, size: 32.w, color: AppColors.primary),
            ),
            SizedBox(height: 12.h),

            Text(
              "إضافة حجز جديد",
              style: context.typography.lgBold.copyWith(
                color: AppColors.textDisplay,
              ),
            ),
            SizedBox(height: 6.h),

            Text(
              "ابدأ الآن بحجز كشف جديد بكل سهولة",
              style: context.typography.smRegular.copyWith(
                color: AppColors.textSecondaryParagraph,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
