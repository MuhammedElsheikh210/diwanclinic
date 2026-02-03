import '../../../index/index_main.dart';
import 'sync_medicine_view_model.dart';

class SyncMedicineView extends StatelessWidget {
  const SyncMedicineView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background_neutral_100,
      body: Center(
        child: GetBuilder<SyncMedicineViewModel>(
          init: SyncMedicineViewModel(),
          builder: (controller) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// ICON
                  Container(
                    width: 110.w,
                    height: 110.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.85),
                          AppColors.primary.withOpacity(0.4),
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.medical_services_rounded,
                      color: AppColors.white,
                      size: 52.sp,
                    ),
                  ),

                  SizedBox(height: 28.h),

                  /// TITLE
                  Text(
                    "تجهيز قاعدة بيانات الأدوية",
                    style: context.typography.xlBold.copyWith(
                      color: AppColors.textDisplay,
                    ),
                  ),

                  SizedBox(height: 12.h),

                  /// SUBTITLE
                  Text(
                    "يتم إعداد البيانات محليًا لأول مرة فقط",
                    textAlign: TextAlign.center,
                    style: context.typography.mdRegular.copyWith(
                      color: AppColors.textSecondaryParagraph,
                    ),
                  ),

                  SizedBox(height: 36.h),

                  /// LOADER
                  const CircularProgressIndicator(
                    color: AppColors.primary,
                  ),

                  SizedBox(height: 24.h),

                  /// INFO
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14.r),
                      color: AppColors.primary.withOpacity(0.06),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            "قد تستغرق هذه الخطوة ثوانٍ قليلة فقط",
                            style: context.typography.smRegular.copyWith(
                              color: AppColors.textSecondaryParagraph,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
