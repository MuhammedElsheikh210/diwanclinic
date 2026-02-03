import 'package:url_launcher/url_launcher.dart';

import '../../../../index/index_main.dart';

class ForceUpdateView extends StatelessWidget {
  const ForceUpdateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary_faint,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// 🖼️ Logo / Illustration
              Image.asset(
                Images.splash,
                width: 220.w,
                height: 220.w,
                fit: BoxFit.contain,
              ),

              SizedBox(height: 32.h),

              /// 🔔 Title
              Text(
                "تحديث مطلوب",
                textAlign: TextAlign.center,
                style: context.typography.lgBold.copyWith(
                  color: AppColors.textDisplay,
                ),
              ),

              SizedBox(height: 12.h),

              /// 📝 Description
              Text(
                "لضمان أفضل تجربة واستخدام أحدث الميزات، "
                "يرجى تحديث تطبيق لينك إلى أحدث إصدار.",
                textAlign: TextAlign.center,
                style: context.typography.mdRegular.copyWith(
                  color: AppColors.background_black,
                  height: 1.6,
                ),
              ),

              SizedBox(height: 40.h),

              /// 🚀 Update Button
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: _openStore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    "تحديث الآن",
                    style: context.typography.mdMedium.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              /// 🔒 Footer Note
              Text(
                "لا يمكن استخدام التطبيق بدون التحديث",
                style: context.typography.smRegular.copyWith(
                  color: AppColors.errorForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openStore() async {
    final url = ConstantsData.deviceType() == "ios"
        ? Strings.url_ios
        : Strings.url_android;

    final uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
}
