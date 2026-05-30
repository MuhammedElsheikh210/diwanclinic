import 'dart:async';
import 'package:diwanclinic/Presentation/design_systems/animation/generic_animation_widget.dart';
import '../../../../index/index_main.dart';

class OrderSuccessView extends StatefulWidget {
  const OrderSuccessView({super.key});

  @override
  State<OrderSuccessView> createState() => _OrderSuccessViewState();
}

class _OrderSuccessViewState extends State<OrderSuccessView> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(const Duration(seconds: 6), () {
      if (mounted) {
        Get.until((route) => route.isFirst);
        if (Get.isRegistered<MainPageViewModel>()) {
          Get.find<MainPageViewModel>().changeIndex(0);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // ✅ يمنع memory leak
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Stack(
            alignment: Alignment.center,
            children: [
              /// 🎬 Background Animation
              const GenericAnimationWidget(
                animation_file_name: Animations.success,
              ),

              /// 📋 Content Overlay
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// 💊 Title
                  Text(
                    "تم إرسال طلب العلاج بنجاح",
                    style: typography.lgBold,
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 12.h),

                  /// 📦 Description
                  Text(
                    "تم استلام طلب الروشتة بنجاح.\n"
                    "سيتم مراجعة الروشتة من الصيدلية وتجهيز العلاج.\n"
                    "سيتم التواصل معك لتأكيد السعر وموعد التوصيل.",
                    style: typography.mdMedium.copyWith(height: 1.6),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 100.h),

                  SizedBox(
                    width: double.infinity,
                    height: 55.h,
                    child: PrimaryTextButton(
                      label: AppText(
                        text: "عرض طلباتي",
                        textStyle: typography.mdMedium.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      onTap: () {
                        _timer?.cancel();
                        Get.until((route) => route.isFirst);
                        if (Get.isRegistered<MainPageViewModel>()) {
                          Get.find<MainPageViewModel>().changeIndex(2);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
