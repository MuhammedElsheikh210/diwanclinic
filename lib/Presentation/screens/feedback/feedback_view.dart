import '../../../../../index/index_main.dart';

class DoctorFeedbackView extends StatelessWidget {
  const DoctorFeedbackView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DoctorFeedbackViewModel>(
      init: DoctorFeedbackViewModel(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            title: Text("آراء المرضى", style: context.typography.lgBold),
            backgroundColor: AppColors.white,
            elevation: 1,
          ),
          body: controller.listReviews == null
              ? const ShimmerFeedbackLoader()
              : controller.listReviews!.isEmpty
              ? const NoDataWidget()
              : Column(
                  children: [
                    // 🔹 Banner Section
                    _buildSummaryBanner(context, controller),

                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                          vertical: 15.h,
                          horizontal: 5.w,
                        ),
                        itemCount: controller.listReviews!.length,
                        itemBuilder: (context, index) {
                          final review = controller.listReviews![index];
                          return DoctorFeedbackCard(
                            review: review ?? DoctorReviewModel(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildSummaryBanner(
    BuildContext context,
    DoctorFeedbackViewModel controller,
  ) {
    final totalReviews = controller.listReviews?.length ?? 0;
    final avgRating = totalReviews > 0
        ? (controller.listReviews!
                  .where((r) => r != null && r!.rateValue != null)
                  .map((r) => r!.rateValue!)
                  .fold<int>(0, (a, b) => a + b) /
              totalReviews)
        : 0.0;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(12.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 🔹 Total Patients
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "إجمالي التقييمات",
                style: context.typography.smMedium.copyWith(
                  color: AppColors.textSecondaryParagraph,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                "$totalReviews مريض",
                style: context.typography.lgBold.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          // 🔹 Average Rating
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "متوسط التقييم",
                style: context.typography.smMedium.copyWith(
                  color: AppColors.textSecondaryParagraph,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Text(
                    avgRating.toStringAsFixed(1),
                    style: context.typography.lgBold.copyWith(
                      color: AppColors.primary,
                      fontSize: 18.sp,
                    ),
                  ),
                  Text(
                    " / 5",
                    style: context.typography.smRegular.copyWith(
                      color: AppColors.textSecondaryParagraph,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
