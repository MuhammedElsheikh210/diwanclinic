import 'package:intl/intl.dart';

import '../../../../../index/index_main.dart';

class DoctorFeedbackCard extends StatelessWidget {
  final DoctorReviewModel review;

  const DoctorFeedbackCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderNeutralPrimary, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 Patient Name + Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review.patientName ?? "مريض غير معروف",
                style: context.typography.mdBold.copyWith(
                  color: AppColors.textDefault,
                  fontSize: 15,
                ),
              ),
              Text(
                _formatDate(review.createdAt),
                style: context.typography.smRegular.copyWith(
                  color: AppColors.textSecondaryParagraph,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          /// 🔹 Comment
          Text(
            review.comment ?? "لا يوجد تعليق",
            style: context.typography.mdRegular.copyWith(
              color: AppColors.textDefault,
              height: 1.4,
            ),
          ),
          SizedBox(height: 12.h),

          /// 🔹 Rate (Stars)
          Row(
            children: List.generate(
              5,
                  (index) => Icon(
                index < (review.rateValue ?? 0)
                    ? Icons.star
                    : Icons.star_border,
                color: AppColors.primary,
                size: 20.h,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(int? timestamp) {
    if (timestamp == null) return "";
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat("dd/MM/yyyy").format(date);
  }
}
