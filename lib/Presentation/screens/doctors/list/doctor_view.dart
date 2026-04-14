import '../../../../../index/index_main.dart';
import '../../specializations/lists/create_doctor_suggestion_view.dart';

class DoctorView extends StatefulWidget {
  final String specializeKey;
  final String specializeName;

  const DoctorView({
    super.key,
    required this.specializeKey,
    required this.specializeName,
  });

  @override
  State<DoctorView> createState() => _DoctorViewState();
}

class _DoctorViewState extends State<DoctorView> {
  late final LocalUser user;

  @override
  void initState() {
    super.initState();

    final sessionUser = Get.find<UserSession>().user;

    if (sessionUser == null) {
      throw Exception("User not initialized in session");
    }

    user = sessionUser;
  }

  // ============================================================
  // ROLES
  // ============================================================

  bool get isAdmin => user.user.userType == UserType.admin;

  bool get isSales => user.user.userType == UserType.sales;

  bool get canManageSpecialization => isAdmin || isSales;

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: GetBuilder<DoctorViewModel>(
        init: DoctorViewModel(specializeKey: widget.specializeKey),
        builder: (controller) {
          return Scaffold(
            backgroundColor: AppColors.background_neutral_25,

            // ============================================================
            // APP BAR
            // ============================================================
            appBar: AppBar(
              backgroundColor: AppColors.white,
              elevation: 0.8,
              centerTitle: true,
              title: Text(
                widget.specializeName,
                style: typography.lgBold.copyWith(
                  color: AppColors.textDisplay,
                  fontSize: 23,
                ),
              ),
              iconTheme: const IconThemeData(color: AppColors.textDisplay),
            ),

            // ============================================================
            // FAB
            // ============================================================
            floatingActionButton: InkWell(
              onTap: () {
                if (canManageSpecialization) {
                  Get.to(
                    () => CreateDoctorView(
                      specializeKey: widget.specializeKey,
                      specializName: widget.specializeName,
                    ),
                    binding: Binding(),
                  );
                } else {
                  showCustomBottomSheet(
                    context: context,
                    child: const CreateDoctorSuggestionView(),
                  );
                }
              },
              child: Container(
                height: 55.h,
                width: 55.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Svgicon(
                    icon:
                        canManageSpecialization
                            ? IconsConstants.fab_Button
                            : IconsConstants.add,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),

            // ============================================================
            // BODY
            // ============================================================
            body: SafeArea(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async => controller.getData(),
                child:
                    controller.listDoctors == null
                        ? const ShimmerLoader()
                        : controller.listDoctors!.isEmpty
                        ? NoDataAnimated(
                          title: "جاري إضافة الأطباء",
                          subtitle:
                              "نقوم حالياً بتجهيز التخصصات لخدمتك بشكل أفضل",
                          lottiePath: Animations.no_prescription,
                          height: 300.h,
                        )
                        : ListView.separated(
                          padding: EdgeInsets.symmetric(
                            vertical: 16.h,
                            horizontal: 12.w,
                          ),
                          physics: const BouncingScrollPhysics(),
                          itemCount: controller.listDoctors!.length,
                          separatorBuilder: (_, __) => SizedBox(height: 12.h),
                          itemBuilder: (context, index) {
                            final doctor = controller.listDoctors![index];

                            if (doctor == null) {
                              return const SizedBox.shrink();
                            }

                            return InkWell(
                              onTap: () {
                                final user = Get.find<UserSession>().user;
                                print("user doctor is ${user?.user.userType}");
                                if (user?.user.userType == UserType.admin) {
                                  print(
                                    "user doctor is ${user?.user.toJson()}",
                                  );
                                  Get.to(
                                    () => ClinicView(
                                      title: doctor.user.name,
                                      doctorKey: doctor.user.uid,
                                      doctorUser: doctor,
                                    ),
                                    binding: Binding(),
                                  );
                                } else {
                                  Get.to(
                                    () => DoctorDetailsView(doctor: doctor),
                                    binding: Binding(),
                                  );
                                }
                              },
                              child: DoctorCard(
                                doctor: doctor,
                                controller: controller,
                              ),
                            );
                          },
                        ),
              ),
            ),
          );
        },
      ),
    );
  }
}
