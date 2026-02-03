

import '../../../../../index/index_main.dart';
import '../../../../Widgets/cards/epxense_category_card.dart';
import 'category_view_model.dart';

class ExpenseCategoryView extends StatefulWidget {

  const ExpenseCategoryView({super.key,});

  @override
  State<ExpenseCategoryView> createState() => _ExpenseCategoryViewState();
}

class _ExpenseCategoryViewState extends State<ExpenseCategoryView> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white, // Keeps status bar white
        statusBarIconBrightness: Brightness.dark, // Uses dark icons
        statusBarBrightness: Brightness.light, // For iOS devices
      ),
      child: GetBuilder<CategoryExpenseViewModel>(
        init: CategoryExpenseViewModel(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: ColorMappingImpl().white,
            appBar: AppBar(
              title: Text(
                "تصنيف الإلتزامات",
                style: context.typography.lgBold,
              ),
              elevation: 0,
              backgroundColor: AppColors.white,
            ),
            floatingActionButton: InkWell(
              onTap: () {
                Get.delete<CreateCategoryViewModel>();
                showCustomBottomSheet(
                  context: context,
                  child: const CreateExpenseCategoryView(),
                );
              },
              child: const Svgicon(icon: IconsConstants.fab_Button),
            ),
            body:
                controller.listCategories == null
                    ? const ShimmerLoader()
                    : controller.listCategories!.isEmpty
                    ? const NoDataWidget(title: '', image: '')
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
                          child: ExpenseCategoryCard(
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
