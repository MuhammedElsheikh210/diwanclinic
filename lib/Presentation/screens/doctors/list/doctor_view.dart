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
  late final user = LocalUser().getUserData();

  bool get isAdmin => user.userType?.name == 'admin';

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
            appBar: AppBar(
              backgroundColor: AppColors.white,
              elevation: 0.8,
              centerTitle: true,
              title: Text(
                "الأطباء",
                style: typography.lgBold.copyWith(color: AppColors.textDisplay),
              ),
              iconTheme: const IconThemeData(color: AppColors.textDisplay),
            ),

            // ✅ Show FAB only if user is admin
            floatingActionButton: InkWell(
              onTap: () {
                if (isAdmin) {
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
                    icon: isAdmin
                        ? IconsConstants.fab_Button
                        : IconsConstants.add,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),

            // ✅ Main content
            body: SafeArea(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async => controller.getData(),
                child: controller.listDoctors == null
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
                          if (doctor == null) return const SizedBox.shrink();

                          return InkWell(
                            onTap: () {
                              Get.to(() => DoctorDetailsView(doctor: doctor));
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
