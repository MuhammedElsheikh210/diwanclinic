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
              onTap: () {
                Get.delete<CreatePharmacyViewModel>();
                showCustomBottomSheet(
                  context: context,
                  child: const CreatePharmacyView(),
                );
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
