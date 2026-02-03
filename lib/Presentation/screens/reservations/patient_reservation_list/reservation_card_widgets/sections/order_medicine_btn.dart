import '../../../../../../../index/index_main.dart';

class OrderMedicineWidget extends StatelessWidget {
  final VoidCallback onTap;
  final bool isOrdered;

  const OrderMedicineWidget({
    super.key,
    required this.onTap,
    required this.isOrdered,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.typography;

    // ------------------------------------------------
    // ✅ ORDER ALREADY SENT (PLACEHOLDER)
    // ------------------------------------------------
    if (isOrdered) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withValues(alpha: .4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.primary),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "تم طلب العلاج",
                      style: t.mdBold.copyWith(color: AppColors.primary),
                    ),
                    Text(
                      "تم تنفيذ طلب العلاج من خلالنا، وسنتابع معك حتى اكتمال الخدمة.",
                      style: t.xsRegular.copyWith(
                        color: AppColors.textSecondaryParagraph,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ------------------------------------------------
    // 🟢 CTA – ORDER MEDICINE
    // ------------------------------------------------
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_pharmacy, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  "اطلب العلاج الان",
                  style: t.mdBold.copyWith(color: AppColors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "بعد انتهاء الكشف، ارفع الروشتة واطلب العلاج بسهولة، وإحنا نوصّلهولك بأفضل سعر.",

            style: t.smRegular.copyWith(
              color: AppColors.textSecondaryParagraph,
            ),
          ),
        ],
      ),
    );
  }
}
