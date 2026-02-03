import '../../../../../index/index_main.dart';

class CategoryView extends StatefulWidget {
  final String? title;

  const CategoryView({super.key, this.title});

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white, // Keeps status bar white
        statusBarIconBrightness: Brightness.dark, // Uses dark icons
        statusBarBrightness: Brightness.light, // For iOS devices
      ),
      child: GetBuilder<CategoryViewModel>(
        init: CategoryViewModel(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: ColorMappingImpl().white,
            appBar: AppBar(
              title: Text(
                widget.title ?? "التصنيفات",
                style: context.typography.lgBold,
              ),
              elevation: 1,
              backgroundColor: AppColors.white,
            ),
            floatingActionButton: InkWell(
              onTap: () {
                Get.delete<CreateCategoryViewModel>();
                showCustomBottomSheet(
                  context: context,
                  child: const CreateCategoryView(),
                );
              },
              child: const Svgicon(icon: IconsConstants.fab_Button),
            ),
            body: controller.listCategories == null
                ? const ShimmerLoader()
                : controller.listCategories!.isEmpty
                ? const NoDataWidget()
                : ListView.builder(
                    padding: EdgeInsets.symmetric(
                      vertical: 15.h,
                      horizontal: 5.w,
                    ),
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.listCategories!.length,
                    itemBuilder: (BuildContext context, int index) {
                      final category = controller.listCategories![index];
                      return Padding(
                        padding: EdgeInsets.only(
                          left: 10.0.w,
                          right: 10.0.w,
                          bottom: 5.h,
                        ),
                        child: CategoryCard(
                          categoryEntity: category ?? const CategoryEntity(),
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
