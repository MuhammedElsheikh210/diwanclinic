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
                            const MarketingBannerWidget(),
                            SizedBox(height: 10.h),

                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: HomeFeatureTile(
                                      title: "احجز كشف",
                                      subtitle: "تابع دورك لحظة بلحظة ",
                                      icon: Icons.calendar_month_rounded,
                                      color: AppColors.primary,
                                      onTap: () {
                                        Get.to(
                                          () => const SpecializationView(),
                                        );
                                      },
                                    ),
                                  ),

                                  SizedBox(width: 12.w),

                                  Expanded(
                                    child: HomeFeatureTile(
                                      title: "اطلب علاجك",
                                      subtitle: "توصيل العلاج لحد باب البيت",
                                      icon: Icons.medical_services_rounded,
                                      color: const Color(0xFFFF6B35),
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
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 16.h),

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
        duration: const Duration(milliseconds: 130),
        scale: isPressed ? 0.96 : 1.0,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 14.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: widget.color.withOpacity(0.14),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.10),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 58.w,
                height: 58.w,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, color: widget.color, size: 27.sp),
              ),
              SizedBox(height: 12.h),
              Text(
                widget.title,
                style: context.typography.mdBold.copyWith(
                  color: AppColors.textDisplay,
                  fontSize: 15.sp,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 5.h),
              Text(
                widget.subtitle,
                style: context.typography.smRegular.copyWith(
                  color: AppColors.textSecondaryParagraph,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
