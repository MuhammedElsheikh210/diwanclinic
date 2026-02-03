import 'package:diwanclinic/Presentation/screens/order_medicine_view/order_medicine_view.dart';

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
                child: controller.isLoading
                    ? SizedBox(
                        height: ScreenUtil().screenHeight * 0.5.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.only(left: 10, right: 10.h),
                          itemBuilder: (_, __) => SizedBox(
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
                            child: Column(
                              children: [
                                HomeFeatureTile(
                                  title: "احجز كشف",
                                  subtitle:
                                      "تابع دورك لحظة بلحظة واستقبل التحديثات فورًا",
                                  icon: Icons.calendar_month,
                                  color: AppColors.primary,
                                  onTap: () {
                                    Get.to(() => const SpecializationView());
                                  },
                                ),

                                SizedBox(height: 12.h),

                                HomeFeatureTile(
                                  title: "اطلب علاج بخصم",
                                  subtitle:
                                      "خصم يصل إلى 10٪ وتوصيل العلاج لحد باب البيت",
                                  icon: Icons.medical_services,
                                  color: AppColors.successForeground,
                                  onTap: () {
                                    // Build reservation with urls
                                    final reservation = ReservationModel(
                                      patientKey: LocalUser().getUserData().key,
                                      patientUid: LocalUser().getUserData().uid,
                                      fcmToken_patient: LocalUser()
                                          .getUserData()
                                          .fcmToken,
                                      patientPhone: LocalUser()
                                          .getUserData()
                                          .phone,
                                      patientName: LocalUser()
                                          .getUserData()
                                          .name,
                                    );

                                    Get.to(
                                      () => OrderMedicineScreen(
                                        reservation: reservation,
                                        onConfirmed: (ReservationModel p1) {
                                          // controller.updateReservation(p1);
                                          Get.offAll(
                                            () =>
                                                const MainPage(initialIndex: 2),
                                            binding: Binding(),
                                          );
                                        },
                                      ),
                                      binding: Binding(),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

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

class HomeFeatureTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      splashColor: color.withOpacity(0.08),
      highlightColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.grayLight.withOpacity(0.45)),
        ),
        child: Row(
          children: [
            /// 🔹 Leading icon
            Container(
              width: 46.w,
              height: 46.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),

            SizedBox(width: 14.w),

            /// 🔹 Title + Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.typography.mdMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.typography.smMedium.copyWith(
                      color: AppColors.grayMedium,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            /// 🔹 Trailing chevron
            Icon(
              Icons.chevron_right, // RTL-friendly
              color: AppColors.grayLight,
              size: 22.sp,
            ),
          ],
        ),
      ),
    );
  }
}
