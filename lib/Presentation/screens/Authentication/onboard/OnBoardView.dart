// ignore_for_file: library_private_types_in_public_api, non_constant_identifier_names, depend_on_referenced_packages




import '../../../../index/index_main.dart';

class OnBoardView extends StatefulWidget {
  int currentPage = 0;

  OnBoardView({Key? key}) : super(key: key);

  @override
  _OnBoardBodyState createState() => _OnBoardBodyState();
}

class _OnBoardBodyState extends State<OnBoardView>
    with SingleTickerProviderStateMixin {
  late PageController pageController;
  late AnimationController animationController;
  late Animation<double> animation;

  List<Map<String, String>> onboardList = [
    {
      "text": "جودة عالية",
      "body": "نقدم خدمات تنظيف بجودة عالية\nتضمن رضا عملائنا الكرام.",
      "image": Images.logo,
    },
    {
      "text": "أسعار تنافسية",
      "body": "نضمن لكم أفضل الأسعار\nمع الحفاظ على أعلى مستوى من الخدمة.",
      "image": Images.logo,
    },
    {
      "text": "الأمانة والموثوقية",
      "body": "نحرص على الأمانة والموثوقية\nفي جميع خدماتنا.",
      "image": Images.logo,
    },
  ];

  @override
  void initState() {
    super.initState();
    pageController = PageController();

    // Initialize animation controller
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: ColorResources.COLOR_white,
        bottomNavigationBar: SafeArea(
          child: BottomNavigationView(
            rightwidget: Expanded(
              flex: 2,
              child: InkWell(
                onTap: () {
                  NavigateToLogin();
                },
                child: Text(
                  "تخطي", // Skip
                  style: context.typography.mdBold,
                ),
              ),
            ),
            leftwidget: Expanded(
              flex: 1,
              child: CustomButtonWidget(
                width: MediaQuery.of(context).size.width,
                height: 45.h,
                onpress: () {
                  if (widget.currentPage == 2) {
                    NavigateToLogin();
                  } else {
                    setState(() {
                      pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.ease,
                      );
                      widget.currentPage += 1;
                    });
                  }
                },
                backgroundcolor: ColorResources.COLOR_Primary,
                borderradius: 20,
                text: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "التالي", // Next
                      style: context.typography.mdBold,
                    ),
                    SizedBox(width: 8.w),
                    const Icon(
                      Icons.arrow_forward,
                      color: ColorResources.COLOR_white,
                      size: 15,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! < 0) {
                  // Swipe Left
                  if (widget.currentPage < onboardList.length - 1) {
                    setState(() {
                      pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.ease,
                      );
                      widget.currentPage++;
                    });
                  }
                } else if (details.primaryVelocity! > 0) {
                  // Swipe Right
                  if (widget.currentPage > 0) {
                    setState(() {
                      pageController.previousPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.ease,
                      );
                      widget.currentPage--;
                    });
                  }
                }
              },
              onTap: () {
                // Action when tapping the image
                showImageInfo();
              },
              child: AnimatedBuilder(
                animation: animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (0.2 * animation.value),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Image(
                        width: ScreenUtil().screenWidth,
                        height: ScreenUtil().screenHeight * 0.7,
                        image: AssetImage(
                          onboardList[widget.currentPage]["image"] ?? "",
                        ),
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: PageView.builder(
                onPageChanged: (value) {
                  setState(() {
                    widget.currentPage = value;
                    animationController.forward(from: 0.0);
                  });
                },
                itemCount: onboardList.length,
                controller: pageController,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(onboardList.length, (index) {
                          bool isSelected = widget.currentPage == index;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            width: isSelected ? 20 : 10,
                            // Larger width for the selected dot
                            height: 10,
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? ColorResources.COLOR_Primary
                                      : ColorResources.COLOR_GREY70,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          );
                        }),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: 15.0.h,
                          bottom: 5.h,
                        ),
                        child: Text(
                          onboardList[widget.currentPage]["text"] ?? "",
                          style: context.typography.mdBold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          onboardList[widget.currentPage]["body"] ?? "",
                          style: context.typography.mdMedium,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showImageInfo() {
    Get.snackbar(
      "معلومات الصورة",
      "لقد نقرت على الصورة في الصفحة ${widget.currentPage + 1}",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> NavigateToLogin() async {
    OnboardLocalCheck(firstOpen: true).saveOnBoardLocal();

    Get.offAll(
      () => MainPage(),
      duration: const Duration(milliseconds: 0),
      binding: Binding(),
      transition: Transition.cupertino,
    );
  }
}
