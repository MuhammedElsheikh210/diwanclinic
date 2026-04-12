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
                : ListView.builder(
                    padding: EdgeInsets.symmetric(
                      vertical: 15.h,
                      horizontal: 5.w,
                    ),
                    itemCount: controller.listPharmacies!.length,
                    itemBuilder: (context, index) {
                      final pharmacy = controller.listPharmacies![index];
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 5.h,
                          horizontal: 10.w,
                        ),
                        child: PharmacyCard(
                          pharmacy: pharmacy,
                          controller: controller,
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
