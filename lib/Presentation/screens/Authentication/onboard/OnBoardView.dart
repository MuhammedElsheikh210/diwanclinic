// ignore_for_file: library_private_types_in_public_api, non_constant_identifier_names, depend_on_referenced_packages

import '../../../../index/index_main.dart';

class OnBoardView extends StatefulWidget {
  const OnBoardView({super.key});

  @override
  State<OnBoardView> createState() => _OnBoardViewState();
}

class _OnBoardViewState extends State<OnBoardView> {
  final PageController _controller = PageController();
  int currentPage = 0;

  final List<Map<String, String>> onboardList = [
    {
      "title": "اختر طبيبك بسهولة",
      "body": "تصفح قائمة الأطباء واختر الأنسب لك حسب التخصص والتقييم.",
      "image": Images.onboard_1,
    },
    {
      "title": "احجز موعدك في ثواني",
      "body": "حدد الموعد المناسب لك وتابع دورك لحظة بلحظة بكل سهولة.",
      "image": Images.onboard_2,
    },
    {
      "title": "اطلب علاجك بخصم",
      "body": "اطلب العلاج بعد الكشف واستلمه حتى باب منزلك بأفضل سعر.",
      "image": Images.onboard_3,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            /// Skip
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _navigateNext,
                  child: Text(
                    "تخطي",
                    style: context.typography.mdMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),

            /// Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: onboardList.length,
                onPageChanged: (index) {
                  setState(() => currentPage = index);
                },
                itemBuilder: (_, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /// Image
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          height: 280.h,
                          child: Image.asset(
                            onboardList[index]["image"]!,
                            fit: BoxFit.contain,
                          ),
                        ),

                        SizedBox(height: 40.h),

                        /// Title
                        Text(
                          onboardList[index]["title"]!,
                          textAlign: TextAlign.center,
                          style: context.typography.lgBold.copyWith(
                            color: AppColors.primary,
                            fontSize: 24.sp,
                          ),
                        ),

                        SizedBox(height: 16.h),

                        /// Body
                        Text(
                          onboardList[index]["body"]!,
                          textAlign: TextAlign.center,
                          style: context.typography.mdMedium.copyWith(
                            height: 1.6,
                            color: AppColors.textDefault,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            /// Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardList.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  height: 8.h,
                  width: currentPage == index ? 24.w : 8.w,
                  decoration: BoxDecoration(
                    color: currentPage == index
                        ? AppColors.primary
                        : AppColors.grayLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),

            SizedBox(height: 40.h),

            /// Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: SizedBox(
                width: double.infinity,
                height: 55.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (currentPage == onboardList.length - 1) {
                      _navigateNext();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(
                    currentPage == onboardList.length - 1
                        ? "ابدأ الآن"
                        : "التالي",
                    style: context.typography.mdBold.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  void _navigateNext() async {
    await OnboardLocalCheck(hasSeenOnboard: true).save();

    Get.offAll(() => const LoginView(), binding: Binding());
  }
}
