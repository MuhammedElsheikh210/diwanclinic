import '../../../../../index/index_main.dart';

class MedicalPropertyView extends StatefulWidget {
  final String? title;

  /// ✅ Dynamic category type
  final String? categoryType;

  /// ✅ Current selected category
  final CategoryEntity? categoryEntity;

  const MedicalPropertyView({
    super.key,
    this.title,
    this.categoryType,
    this.categoryEntity,
  });

  @override
  State<MedicalPropertyView> createState() => _MedicalPropertyViewState();
}

class _MedicalPropertyViewState extends State<MedicalPropertyView> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,

        statusBarIconBrightness: Brightness.dark,

        statusBarBrightness: Brightness.light,
      ),

      child: GetBuilder<MedicalPropertyViewModel>(
        init: MedicalPropertyViewModel(
          categoryType: widget.categoryType,

          categoryEntity: widget.categoryEntity,
        ),

        builder: (controller) {
          return Scaffold(
            backgroundColor: ColorMappingImpl().white,

            appBar: AppBar(
              title: Text(
                widget.title ?? "الخصائص",

                style: context.typography.lgBold,
              ),

              elevation: 1,

              backgroundColor: AppColors.white,
            ),

            floatingActionButton: InkWell(
              onTap: () {
                Get.delete<MedicalPropertyCreatsViewmodel>();

                showCustomBottomSheet(
                  context: context,

                  child: MedicalPropertyCreate(
                    categoryType: widget.categoryType,

                    categoryEntity: widget.categoryEntity,
                  ),
                );
              },

              child: const Svgicon(icon: IconsConstants.fab_Button),
            ),

            body:
                controller.listProperties == null
                    ? const ShimmerLoader()
                    : controller.listProperties!.isEmpty
                    ? const NoDataWidget()
                    : ListView.builder(
                      padding: EdgeInsets.symmetric(
                        vertical: 15.h,

                        horizontal: 5.w,
                      ),

                      shrinkWrap: true,

                      physics: const BouncingScrollPhysics(),

                      itemCount: controller.listProperties!.length,

                      itemBuilder: (BuildContext context, int index) {
                        final property = controller.listProperties![index];

                        return Padding(
                          padding: EdgeInsets.only(
                            left: 10.0.w,

                            right: 10.0.w,

                            bottom: 5.h,
                          ),

                          child: MedicalPropertyCard(
                            property: property ?? MedicalRecordPropertyModel(),
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
