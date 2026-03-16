import 'package:diwanclinic/Presentation/screens/medical_center/centers_list/center_doctors_view.dart';

import '../../../../../index/index_main.dart';
import '../create/create_medical_center_view.dart';

class MedicalCentersView extends StatefulWidget {
  const MedicalCentersView({super.key});

  @override
  State<MedicalCentersView> createState() => _MedicalCentersViewState();
}

class _MedicalCentersViewState extends State<MedicalCentersView> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<MedicalCenterViewModel>(
      init: MedicalCenterViewModel(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.background_neutral_25,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0.8,
            centerTitle: true,
            title: Text(
              "المراكز الطبية",
              style: context.typography.lgBold.copyWith(
                color: AppColors.textDisplay,
              ),
            ),
          ),

          /// ➕ Add Center
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.primary,
            onPressed: () {
              Get.to(() => const CreateMedicalCenterView());
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),

          /// 📋 Centers List
          body: SafeArea(
            child:
                controller.centers == null
                    ? const ShimmerLoader()
                    : controller.centers!.isEmpty
                    ? const NoDataWidget()
                    : ListView.separated(
                      padding: EdgeInsets.symmetric(
                        vertical: 16.h,
                        horizontal: 12.w,
                      ),
                      physics: const BouncingScrollPhysics(),
                      itemCount: controller.centers!.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final center = controller.centers![index];
                        if (center == null) {
                          return const SizedBox.shrink();
                        }

                        return InkWell(
                          borderRadius: BorderRadius.circular(16.r),
                          onTap: () {
                            /// 🔥 Go to Doctors of this Center
                            Get.to(() => CenterDoctorsView(center: center));
                          },
                          child: MedicalCenterCard(center: center),
                        );
                      },
                    ),
          ),
        );
      },
    );
  }
}
