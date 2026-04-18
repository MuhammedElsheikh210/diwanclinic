import 'package:diwanclinic/Presentation/screens/medical_center/centers_list/create_assistant_for_center_view.dart';

import '../../../../../index/index_main.dart';

class CenterDoctorsView extends StatefulWidget {
  final MedicalCenterModel center;

  const CenterDoctorsView({super.key, required this.center});

  @override
  State<CenterDoctorsView> createState() => _CenterDoctorsViewState();
}

class _CenterDoctorsViewState extends State<CenterDoctorsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleFabAction() {
    /// 👨‍⚕️ Doctors Tab
    if (_tabController.index == 0) {
      Get.to(
        () => CreateDoctorView(
          specializeKey: "",
          medicalCenterKey: widget.center.key,
        ),
      );
    }
    /// 🧑‍💼 Assistants Tab
    else {
      Get.bottomSheet(
        CreateAssistantViewForCenter(medicalCenterKey: widget.center.key!),
        isScrollControlled: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background_neutral_25,

      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0.8,
        centerTitle: true,
        title: Text(
          widget.center.name ?? "إدارة المركز",
          style: context.typography.lgBold.copyWith(
            color: AppColors.textDisplay,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [Tab(text: "الدكاترة"), Tab(text: "المساعدين")],
        ),
      ),

      /// ➕ Dynamic FAB
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _handleFabAction,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      /// 📋 Tab Views
      body: TabBarView(
        controller: _tabController,
        children: [
          /// ================== 👨‍⚕️ DOCTORS TAB ==================
          GetBuilder<DoctorViewModel>(
            builder: (controller) {
              return controller.listDoctors == null
                  ? const ShimmerLoader()
                  : controller.listDoctors!.isEmpty
                  ? const NoDataWidget()
                  : ListView.separated(
                    padding: EdgeInsets.symmetric(
                      vertical: 16.h,
                      horizontal: 12.w,
                    ),
                    itemCount: controller.listDoctors!.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (_, index) {
                      final doctor = controller.listDoctors![index];
                      if (doctor == null) {
                        return const SizedBox.shrink();
                      }

                      return DoctorCard(
                        fromAdmin: true,
                        doctor: doctor,
                        controller: controller,
                      );
                    },
                  );
            },
          ),

          /// ================== 🧑‍💼 ASSISTANTS TAB ==================
          GetBuilder<AssistantViewModel>(
            init: AssistantViewModel.byCenter(widget.center.key ?? ""),
            builder: (controller) {
              return controller.listAssistants == null
                  ? const ShimmerLoader()
                  : controller.listAssistants!.isEmpty
                  ? const NoDataWidget()
                  : ListView.separated(
                    padding: EdgeInsets.symmetric(
                      vertical: 16.h,
                      horizontal: 12.w,
                    ),
                    itemCount: controller.listAssistants!.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (_, index) {
                      final assistant = controller.listAssistants![index];
                      if (assistant == null) {
                        return const SizedBox.shrink();
                      }

                      return AssistantCard(
                        assistant: assistant,
                        controller: controller,
                      );
                    },
                  );
            },
          ),
        ],
      ),
    );
  }
}
