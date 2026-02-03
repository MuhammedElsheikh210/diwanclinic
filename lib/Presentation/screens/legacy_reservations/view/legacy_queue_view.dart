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

          /// 📅 Date Picker AppBar
          appBar: LegacyQueueDateAppBar(controller: controller),

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

          body: controller.list == null
              ? const ShimmerLoader()
              : controller.list!.isEmpty
              ? const NoDataWidget()
              : ListView.builder(
                  itemCount: controller.list!.length,
                  itemBuilder: (_, i) => LegacyQueueCard(
                    model: controller.list![i]!,
                    controller: controller,
                  ),
                ),
        );
      },
    );
  }
}
