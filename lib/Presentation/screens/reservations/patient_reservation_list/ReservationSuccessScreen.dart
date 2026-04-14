import 'package:lottie/lottie.dart';

import '../../../../index/index_main.dart';

class ReservationSuccessScreen extends StatelessWidget {
  final ReservationModel reservation;

  const ReservationSuccessScreen({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// ✅ Success Animation
              Lottie.asset(
                Animations.success,
                height: 400.h,
                repeat: true,
                width: ScreenUtil().screenWidth,
              ),

              /// ✅ Title
              Text(
                "تم تأكيد الحجز بنجاح 🎉",
                textAlign: TextAlign.center,
                style: context.typography.lgBold.copyWith(
                  color: AppColors.primary,
                  fontSize: 22.sp,
                ),
              ),

              SizedBox(height: 12.h),

              /// ✅ Subtitle
              Text(
                "تم إرسال طلب الحجز بنجاح، يمكنك متابعة حالة الحجز من صفحة الحجوزات.",
                textAlign: TextAlign.center,
                style: context.typography.mdMedium.copyWith(
                  height: 1.6,
                  color: AppColors.textDefault,
                ),
              ),

              SizedBox(height: 24.h),

              /// 📄 Reservation Info Card
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.grayLight.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    _infoRow(
                      context,
                      "رقم الحجز",
                      "#${reservation.orderNum ?? '-'}",
                    ),
                    SizedBox(height: 8.h),
                    _infoRow(
                      context,
                      "تاريخ الموعد",
                      reservation.appointmentDateTime ?? "-",
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40.h),

              /// 🔵 Buttons
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () {
                    Get.offAllNamed(mainpage);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ),
                  child: Text(
                    "العودة إلى الرئيسية",
                    style: context.typography.mdBold.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: OutlinedButton(
                  onPressed: () {
                    Get.offAll(
                      () => const MainPage(initialIndex: 1),
                      binding: Binding(),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ),
                  child: Text(
                    "عرض حجوزاتي",
                    style: context.typography.mdBold.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.typography.smMedium.copyWith(
            color: AppColors.textSecondaryParagraph,
          ),
        ),
        Text(
          value,
          style: context.typography.mdBold.copyWith(
            color: AppColors.textDefault,
          ),
        ),
      ],
    );
  }
}
