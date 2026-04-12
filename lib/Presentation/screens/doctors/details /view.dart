import '../../../../../index/index_main.dart';

class DoctorDetailsView extends StatelessWidget {
  final LocalUser doctor;

  const DoctorDetailsView({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;

    final d = doctor.asDoctor; // ✅ الحل

    return GetBuilder<DoctorDetailsViewModel>(
      init: DoctorDetailsViewModel(doctor: doctor),
      builder: (controller) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: AppColors.white,
            statusBarIconBrightness: Brightness.dark,
          ),
          child: Scaffold(
            backgroundColor: AppColors.background_neutral_25,

            // ================= APP BAR =================
            appBar: AppBar(
              backgroundColor: AppColors.white,
              centerTitle: true,
              title: Text(
                doctor.name ?? "",
                style: typography.lgBold.copyWith(
                  color: AppColors.textDisplay,
                ),
              ),
              iconTheme: const IconThemeData(color: AppColors.textDisplay),
            ),

            // ================= BUTTON =================
            bottomNavigationBar: SafeArea(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                width: double.infinity,
                child: PrimaryTextButton(
                  appButtonSize: AppButtonSize.xxLarge,
                  label: AppText(
                    text: "إبدأ الحجز",
                    textStyle: typography.mdBold.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  onTap: () {
                    showCustomBottomSheet(
                      context: context,
                      child: SelectReservationDateBottomSheet(
                        controller: controller,
                        transfer_phone: d?.phone ?? "", // ✅ FIX
                        wallet_type:
                        0, // ✅ لو عندك InstaPay ضيفه في DoctorUser
                      ),
                    );
                  },
                ),
              ),
            ),

            // ================= BODY =================
            body: SafeArea(
              child: controller.isLoadingClinics
                  ? const ShimmerLoader()
                  : ListView(
                children: [
                  // ================= IMAGE =================
                  InkWell(
                    onTap: () => Get.to(
                          () => FullScreenImageView(
                        imageUrl: doctor.profileImage ?? "",
                      ),
                    ),
                    child: Container(
                      width: 150.w,
                      height: 150.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(
                            doctor.profileImage ??
                                "https://via.placeholder.com/150x150?text=Profile",
                          ),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  // ================= QUALIFICATIONS =================
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 10,
                    ),
                    child: Text(
                      d?.doctorQualifications ?? "", // ✅ FIX
                      style: context.typography.mdMedium.copyWith(
                        color: AppColors.background_black,
                      ),
                    ),
                  ),

                  // ================= TABS =================
                  DoctorTabsWidget(controller: controller),

                  // ================= CONTENT =================
                  if (controller.selectedTabIndex == 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                      ),
                      child: ClinicAndShiftSection(
                        controller: controller,
                        showFromHome: false,
                      ),
                    )
                  else if (controller.selectedTabIndex == 1)
                    DoctorReviewsWidget(controller: controller)
                  else if (controller.selectedTabIndex == 2)
                      DoctorContactWidget(doctor: doctor),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}