import '../../../../index/index_main.dart';

class OpenclosereservationView extends StatelessWidget {
  const OpenclosereservationView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OpenclosereservationViewModel>(
      init: OpenclosereservationViewModel(),
      builder: (controller) {
        final bool isClosedDay = controller.isSelectedDayClosed;

        return Scaffold(
          backgroundColor: AppColors.white,

          /// 📅 Date Picker AppBar
          appBar: AppBar(
            backgroundColor: AppColors.white,
            title: Text("إدارة أيام العمل", style: context.typography.lgBold),
          ),

          /// ➕ Add / Edit Day
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

          body:
              controller.list == null
                  ? const ShimmerLoader()
                  : controller.list!.isEmpty
                  ? const NoDataWidget()
                  : ListView.builder(
                    itemCount: controller.list!.length,
                    itemBuilder:
                        (_, i) => OpenclosereservationCard(
                          model: controller.list![i]!,
                          controller: controller,
                        ),
                  ),
        );
      },
    );
  }
}
