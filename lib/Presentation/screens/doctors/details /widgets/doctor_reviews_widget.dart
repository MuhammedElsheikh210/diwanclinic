import '../../../../../index/index_main.dart';
import 'package:intl/intl.dart';

class DoctorReviewsWidget extends StatelessWidget {
  final DoctorDetailsViewModel controller;

  const DoctorReviewsWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;

    // If no reviews
    if (controller.listReviews == null || controller.listReviews!.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 80.h, horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.reviews_rounded,
                color: AppColors.textSecondaryParagraph,
                size: 60,
              ),
              SizedBox(height: 12.h),
              Text(
                "لا توجد تقييمات بعد",
                style: typography.lgBold.copyWith(
                  color: AppColors.textSecondaryParagraph,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                "سيظهر هنا تقييمات المرضى بعد زيارتهم للطبيب",
                textAlign: TextAlign.center,
                style: typography.smRegular.copyWith(
                  color: AppColors.textSecondaryParagraph.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      itemCount: controller.listReviews!.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final review = controller.listReviews![index];
        if (review == null) return const SizedBox();

        return _ReviewCard(review: review);
      },
    );
  }
}

// ─────────────────────────────────────────────
// 🔹 Review Card Widget
// ─────────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  final DoctorReviewModel review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;

    final formattedDate = review.createdAt != null
        ? DateFormat(
            'dd MMM yyyy',
            'ar',
          ).format(DateTime.fromMillisecondsSinceEpoch(review.createdAt!))
        : "";

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowUpper.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: AppColors.borderNeutralPrimary.withOpacity(0.3),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 👤 Patient Name + Date
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary10,
                child: Icon(
                  Icons.person_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.patientName ?? "مريض غير معروف",
                      style: typography.mdBold.copyWith(
                        color: AppColors.textDisplay,
                      ),
                    ),
                    if (formattedDate.isNotEmpty)
                      Text(
                        formattedDate,
                        style: typography.smRegular.copyWith(
                          color: AppColors.textSecondaryParagraph,
                        ),
                      ),
                  ],
                ),
              ),
              // ⭐ Rating Stars
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (starIndex) {
                  final isFilled = (review.rateValue ?? 0) > starIndex;
                  return Icon(
                    Icons.star_rounded,
                    size: 18.sp,
                    color: isFilled
                        ? AppColors.yellowForeground
                        : AppColors.grayLight,
                  );
                }),
              ),
            ],
          ),

          // 💬 Comment
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(
              review.comment!,
              style: typography.mdRegular.copyWith(
                color: AppColors.text_primary_paragraph,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
