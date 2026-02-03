import '../../../../../index/index_main.dart';

class CategoryViewModel extends GetxController {
  List<CategoryEntity?>? listCategories;

  @override
  Future<void> onInit() async {
    getData();
    super.onInit();
  }

  /// ✅ Fetch Categories from API
  void getData() {
    CategoryService().getAllCategoriesData(
      filterParams: SQLiteQueryParams(
        where: "name = ? AND uid = ?",
        whereArgs: ["test 3", "c4S7jazfPIWCZZnRToV1hH3IXOD2"],
        // orderBy: 'create_at ${Strings.desc}',
        is_filtered: true
      ),
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
