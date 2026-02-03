import '../../../index/index_main.dart';

class SyncView extends StatelessWidget {
  const SyncView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background_neutral_100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        centerTitle: true,
        title: Text(
          "مزامنة البيانات",
          style: context.typography.lgBold.copyWith(
            color: AppColors.textDisplay,
          ),
        ),
      ),
      body: GetBuilder<SyncViewModel>(
        init: SyncViewModel(),
        builder: (controller) {
          return Center(
            child: Obx(() {
              final percent = (controller.progress.value * 100)
                  .clamp(0, 100)
                  .toStringAsFixed(0);

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// 🔹 Sync Icon inside gradient circle
                    Container(
                      width: 100.w,
                      height: 100.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.8),
                            AppColors.primary.withOpacity(0.4),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Icon(
                        Icons.sync_rounded,
                        color: AppColors.white,
                        size: 50.sp,
                      ),
                    ),

                    SizedBox(height: 24.h),

                    /// 🔹 Title
                    Text(
                      "جاري المزامنة...",
                      style: context.typography.xlBold.copyWith(
                        color: AppColors.textDisplay,
                      ),
                    ),

                    SizedBox(height: 12.h),

                    /// 🔹 Subtitle
                    Text(
                      "يرجى الانتظار حتى تكتمل المزامنة",
                      textAlign: TextAlign.center,
                      style: context.typography.mdRegular.copyWith(
                        color: AppColors.textSecondaryParagraph,
                      ),
                    ),

                    SizedBox(height: 36.h),

                    /// 🔹 Progress Bar (flat style)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: LinearProgressIndicator(
                        value: controller.progress.value,
                        minHeight: 12.h,
                        backgroundColor:
                        AppColors.borderNeutralPrimary.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    /// 🔹 Percentage Indicator
                    Text(
                      "$percent%",
                      style: context.typography.xlBold.copyWith(
                        color: AppColors.primary,
                        fontSize: 28.sp,
                      ),
                    ),

                    SizedBox(height: 24.h),

                    /// 🔹 Tip Text
                    Container(
                      padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        color: AppColors.primary.withOpacity(0.06),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.info_outline,
                              color: AppColors.primary, size: 20),
                          SizedBox(width: 8.w),
                          Flexible(
                            child: Text(
                              "تأكد من بقاء التطبيق مفتوحًا أثناء عملية المزامنة",
                              textAlign: TextAlign.center,
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
            }),
          );
        },
      ),
    );
  }
}
