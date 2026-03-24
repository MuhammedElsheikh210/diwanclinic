import '../../../../index/index_main.dart';

class OpenclosereservationView extends StatelessWidget {
  const OpenclosereservationView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OpenclosereservationViewModel>(
      init: OpenclosereservationViewModel(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.white,

          /// 📅 AppBar
          appBar: AppBar(
            backgroundColor: AppColors.white,
            title: Text(
              "إدارة أيام العمل",
              style: context.typography.lgBold,
            ),
          ),

          /// ➕ Add Button
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.primary,
            onPressed: () {
              Get.delete<CreateLegacyQueueViewModel>();
              showCustomBottomSheet(
                context: context,
                child: const CreateOpenclosereservationView(),
              );
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),

          /// 🧠 BODY
          body: Column(
            children: [
              /// 👨‍⚕️ Doctor Dropdown (Center Mode Only)
              if (controller.isCenterMode)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: controller.isLoadingDoctors
                      ? const Center(
                    child: CircularProgressIndicator(),
                  )
                      : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<LocalUser>(
                        isExpanded: true,
                        value: controller.selectedDoctor,
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                        ),
                        items: controller.centerDoctors
                            ?.where((e) => e != null)
                            .map(
                              (doc) => DropdownMenuItem(
                            value: doc,
                            child: Text(
                              doc!.name ?? "",
                              overflow: TextOverflow.ellipsis,
                              style:
                              context.typography.smMedium,
                            ),
                          ),
                        )
                            .toList(),
                        onChanged: (val) async {
                          controller.selectedDoctor = val;

                          /// 🔄 reload data based on doctor
                          await controller.getShiftList();
                          controller.getData();

                          controller.update();
                        },
                      ),
                    ),
                  ),
                ),

              /// 📋 LIST / STATES
              Expanded(
                child: controller.list == null
                    ? const ShimmerLoader()
                    : controller.list!.isEmpty
                    ? const NoDataWidget()
                    : ListView.builder(
                  itemCount: controller.list!.length,
                  itemBuilder: (_, i) =>
                      OpenclosereservationCard(
                        model: controller.list![i]!,
                        controller: controller,
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}