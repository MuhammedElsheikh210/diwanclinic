import '../../../../index/index_main.dart';

class LegacyQueueView extends StatelessWidget {
  const LegacyQueueView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LegacyQueueViewModel>(
      init: LegacyQueueViewModel(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.white,

          /// 📅 AppBar
          appBar: AppBar(
            backgroundColor: AppColors.white,
            title: Text("كشوفات الكشكول", style: context.typography.lgBold),
          ),

          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Get.delete<CreateLegacyQueueViewModel>();
              showCustomBottomSheet(
                context: context,
                child: const CreateLegacyQueueView(),
              );
            },
            child: const Icon(Icons.add),
          ),

          body: Column(
            children: [
              /// 👨‍⚕️ Doctor Dropdown (🔥 ADD THIS)
              if (controller.isCenterMode)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child:
                      controller.isLoadingDoctors
                          ? const Center(child: CircularProgressIndicator())
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
                                items:
                                    controller.centerDoctors
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
                                  if (val == null) return;

                                  await controller.changeDoctor(val);
                                },
                              ),
                            ),
                          ),
                ),

              /// 📋 LIST
              Expanded(
                child:
                    controller.list == null
                        ? const ShimmerLoader()
                        : controller.list!.isEmpty
                        ? const NoDataWidget()
                        : ListView.builder(
                          itemCount: controller.list!.length,
                          itemBuilder:
                              (_, i) => LegacyQueueCard(
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
