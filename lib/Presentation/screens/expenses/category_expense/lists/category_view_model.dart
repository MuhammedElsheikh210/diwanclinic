import '../../../../../index/index_main.dart';

class CategoryExpenseViewModel extends GetxController {
  List<CategoryEntity?>? listCategories;

  @override
  Future<void> onInit() async {
    getData();
    super.onInit();
  }

  /// ✅ Fetch Categories from API
  void getData() {
    CategoryService().getAllCategoriesData(
      filterParams: SQLiteQueryParams(),
      voidCallBack: (data) {
        listCategories = data;
        update();
      },
    );
  }

  /// ✅ Delete a Category
  void deleteCategory(CategoryEntity category) {
    CategoryService().deleteCategoryData(
      category_entity: category,
      voidCallBack: (_) {
        getData();
      },
    );
  }
}
