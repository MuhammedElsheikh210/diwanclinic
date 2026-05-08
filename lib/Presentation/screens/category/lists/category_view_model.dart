import '../../../../../index/index_main.dart';

class CategoryViewModel extends GetxController {
  /// ✅ Dynamic category type
  final String? categoryType;

  CategoryViewModel({this.categoryType});

  List<CategoryEntity?>? listCategories;

  @override
  Future<void> onInit() async {
    getData();
    super.onInit();
  }

  /// ✅ Fetch Categories from API
  void getData() {
    CategoryService().getAllCategoriesData(
      data: {"categoryType": categoryType},

      filterParams: SQLiteQueryParams(),

      voidCallBack: (data) {
        listCategories = data;

        update();
      },
    );
  }

  /// ✅ Delete Category
  void deleteCategory(CategoryEntity category) {
    CategoryService().deleteCategoryData(
      category_entity: category,

      voidCallBack: (_) {
        getData();
      },
    );
  }
}
