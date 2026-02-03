import '../../../../../index/index_main.dart';

class IncomeCard extends StatelessWidget {
  final ReservationModel reservation;

  const IncomeCard({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    final double paid = double.tryParse(reservation.paidAmount ?? "0") ?? 0;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.background_neutral_25,   // خلفية ناعمة شيك
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.borderNeutralPrimary.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          /// ❇ دائرة الأيقونة
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_hospital_rounded,
              color: AppColors.primary,
              size: 22.sp,
            ),
          ),

          SizedBox(width: 14.w),

          /// 👉 تفاصيل اليسار (نوع الكشف فقط)
          Expanded(
            child: Text(
              reservation.reservationType ?? "كشف",
              style: context.typography.lgBold.copyWith(
                color: AppColors.background_black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          /// 👉 السعر
          Text(
            "${paid.toStringAsFixed(2)} ج.م",
            style: context.typography.lgBold.copyWith(
              color: AppColors.successForeground,
              fontSize: 18.sp,
            ),
          ),
        ],
      ),
    );
  }
}
