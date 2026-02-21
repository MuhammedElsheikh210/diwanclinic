import 'package:diwanclinic/Presentation/screens/doctors/list/doctor_view.dart';
import 'package:diwanclinic/Presentation/screens/specializations/create_update/specialize_create.dart';
import 'package:diwanclinic/Presentation/screens/specializations/lists/create_doctor_suggestion_view.dart';
import '../../../../../index/index_main.dart';

class SpecializationView extends StatefulWidget {
  const SpecializationView({super.key});

  @override
  State<SpecializationView> createState() => _SpecializationViewState();
}

class _SpecializationViewState extends State<SpecializationView> {
  late final user = LocalUser().getUserData();

  bool get isAdmin => user.userType?.name == 'admin';

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: GetBuilder<SpecializationViewModel>(
        init: SpecializationViewModel(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: AppBar(
              backgroundColor: AppColors.white,

              title: Text(
                "التخصصات",
                style: context.typography.xlBold.copyWith(
                  color: AppColors.background_black,
                ),
              ),
            ),

            /// ✅ FAB for admin or patient
            floatingActionButton: InkWell(
              onTap: () {
                if (isAdmin) {
                  Get.delete<CreateSpecializeViewModel>();
                  showCustomBottomSheet(
                    context: context,
                    child: const CreateSpecializeyView(),
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

            /// ✅ Main Content
            body: controller.listCategories == null
                ? const ShimmerLoader()
                : controller.listCategories!.isEmpty
                ? const NoDataWidget()
                : Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 10.h,
                    ),
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // ✅ two per row
                        mainAxisSpacing: 10.h,
                        crossAxisSpacing: 10.w,
                        childAspectRatio: 0.8, // good balance for cards
                      ),
                      itemCount: controller.listCategories!.length,
                      itemBuilder: (context, index) {
                        final category = controller.listCategories![index];
                        if (category == null) return const SizedBox.shrink();

                        return InkWell(
                          borderRadius: BorderRadius.circular(16.r),
                          onTap: () => Get.to(
                            () => DoctorView(
                              specializeKey: category.key ?? "",
                              specializeName: category.name ?? "",
                            ),
                          ),
                          child: SpecializeCard(
                            categoryEntity: category,
                            //  controller: controller,
                            showAdminActions: isAdmin,
                          ),
                        );
                      },
                    ),
                  ),
          );
        },
      ),
    );
  }
}
