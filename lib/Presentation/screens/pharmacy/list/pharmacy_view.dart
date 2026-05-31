import '../../../../../index/index_main.dart';

class PharmacyView extends StatefulWidget {
  final String? title;

  const PharmacyView({super.key, this.title});

  @override
  State<PharmacyView> createState() => _PharmacyViewState();
}

class _PharmacyViewState extends State<PharmacyView> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: GetBuilder<PharmacyViewModel>(
        init: PharmacyViewModel(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: AppBar(
              title: Text(
                widget.title ?? "الصيادلة",
                style: context.typography.lgBold,
              ),
              elevation: 1,
              backgroundColor: AppColors.white,
            ),
            floatingActionButton: InkWell(
              onTap: () async {
                Get.delete<CreatePharmacyViewModel>();
                await showModalBottomSheet<void>(
                  context: context,
                  isDismissible: true,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => FractionallySizedBox(
                    heightFactor: 0.85,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(
                        left: 15.w, right: 15.w, bottom: 30.h, top: 20.h,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: const CreatePharmacyView(),
                    ),
                  ),
                );
                controller.getData();
              },
              child: const Svgicon(icon: IconsConstants.fab_Button),
            ),
            body: controller.listPharmacies == null
                ? const ShimmerLoader()
                : controller.listPharmacies!.isEmpty
                ? const NoDataWidget()
                : Builder(builder: (_) {
                    final grouped = controller.groupedPharmacies;
                    final pharmacyIds = grouped.keys.toList();
                    return ListView.builder(
                      padding: EdgeInsets.symmetric(
                        vertical: 15.h,
                        horizontal: 10.w,
                      ),
                      itemCount: pharmacyIds.length,
                      itemBuilder: (context, index) {
                        final pid = pharmacyIds[index];
                        final staffList = grouped[pid]!;
                        // Primary = first in sorted list (uid == pharmacyId)
                        final primary = staffList.first;
                        return PharmacyCard(
                          pharmacy: primary,
                          staffList: staffList,
                          controller: controller,
                        );
                      },
                    );
                  }),
          );
        },
      ),
    );
  }
}
