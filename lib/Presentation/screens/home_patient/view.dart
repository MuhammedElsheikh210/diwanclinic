import '../../../../index/index_main.dart';

class PatientHomeView extends StatefulWidget {
  const PatientHomeView({super.key});

  @override
  State<PatientHomeView> createState() => _PatientHomeViewState();
}

class _PatientHomeViewState extends State<PatientHomeView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("initttttt");
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomePatientController>(
      init: HomePatientController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: const HomePatientAppBar(),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: controller.refreshAll,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child:
                    controller.isLoading
                        ? SizedBox(
                          height: ScreenUtil().screenHeight * 0.5.h,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.only(left: 10, right: 10.h),
                            itemBuilder:
                                (_, __) => SizedBox(
                                  width: ScreenUtil().screenWidth - 50.w,
                                  child: const ReservationCardSkeletonShimmer(),
                                ),
                            separatorBuilder: (_, __) => SizedBox(width: 14.w),
                            itemCount: 3, // number of shimmer cards
                          ),
                        )
                        : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                left: 16.w,
                                right: 16.w,
                                bottom: 12.h,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: HomeFeatureTile(
                                      title: "احجز كشف",
                                      subtitle:
                                          "تابع دورك لحظة بلحظة واستقبل التحديثات فورًا",
                                      icon: Icons.calendar_month,
                                      color: AppColors.primary,
                                      onTap: () {
                                        Get.to(
                                          () => const SpecializationView(),
                                        );
                                      },
                                    ),
                                  ),

                                  SizedBox(height: 12.h),

                                  Expanded(
                                    child: HomeFeatureTile(
                                      title: "اطلب علاج بخصم",
                                      subtitle:
                                          "خصم يصل إلى 10٪ وتوصيل العلاج لحد باب البيت",
                                      icon: Icons.medical_services,
                                      color: AppColors.successForeground,
                                      onTap: () {
                                        final user =
                                            Get.find<UserSession>().user;

                                        final reservation = ReservationModel(
                                          patientUid: user?.uid,
                                          patientFcm: user?.fcmToken,
                                          patientPhone: user?.phone,
                                          patientName: user?.name,
                                        );

                                        Get.to(
                                          () => OrderMedicineScreen(
                                            reservation: reservation,
                                            onConfirmed: (ReservationModel p1) {
                                              Get.off(
                                                () => const OrderSuccessView(),
                                              );
                                            },
                                          ),
                                          binding: Binding(),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10.h),

                            ReservationSectionView(controller: controller),
                            SizedBox(height: 24.h),

                            OrdersSectionView(controller: controller),
                            SizedBox(height: 24.h),

                            SpecializationSectionView(controller: controller),
                            SizedBox(height: 40.h),
                          ],
                        ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class HomeFeatureTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const HomeFeatureTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<HomeFeatureTile> createState() => _HomeFeatureTileState();
}

class _HomeFeatureTileState extends State<HomeFeatureTile> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) => setState(() => isPressed = false),
      onTapCancel: () => setState(() => isPressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: isPressed ? 0.97 : 1,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 22.h, horizontal: 16.w),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24.r),

            // 👇 Border أنعم
            border: Border.all(
              color: widget.color.withOpacity(0.25),
              width: 1.1,
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              /// Arrow in corner
              Positioned(
                left: 0,
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 14.sp,
                  color: Colors.grey.shade400,
                ),
              ),

              /// Main Content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    child: Icon(widget.icon, color: widget.color, size: 28.sp),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: context.typography.mdMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
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
