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
                              child: BookAppointmentCard(
                                onTap: () {
                                  Get.to(() => const SpecializationView());
                                },
                              ),
                            ),

                            SizedBox(height: 16.h),

                            ReservationSectionView(controller: controller),
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

class BookAppointmentCard extends StatefulWidget {
  final VoidCallback onTap;

  const BookAppointmentCard({super.key, required this.onTap});

  @override
  State<BookAppointmentCard> createState() => _BookAppointmentCardState();
}

class _BookAppointmentCardState extends State<BookAppointmentCard> {
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
        scale: isPressed ? 0.97 : 1.0,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 22.h, horizontal: 18.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.82)],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.30),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                    width: 1.2,
                  ),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: Colors.white,
                  size: 30.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "احجز كشف",
                      style: context.typography.lgBold.copyWith(
                        color: Colors.white,
                        fontSize: 19.sp,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      "تابع دورك لحظة بلحظة",
                      style: context.typography.smRegular.copyWith(
                        color: Colors.white.withOpacity(0.85),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                width: 38.w,
                height: 38.w,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios_outlined,
                  color: AppColors.primary,
                  size: 16.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
