
import '../../../../../index/index_main.dart';

class CreateCategoryViewModel extends GetxController {
  /// Controllers for input fields
  final TextEditingController nameController = TextEditingController();

  bool is_update = false;
  CategoryEntity? existingCategory;

  @override
  Future<void> onInit() async {
    super.onInit();
  }

  /// ✅ Populate fields with existing category data
  void populateFields(CategoryEntity category) {
    nameController.text = category.name ?? "";
    is_update = true;
    update();
  }

  /// ✅ Save or update the category
  void saveCategory() {
    final category =
        existingCategory?.copyWith(name: nameController.text) ??
        CategoryEntity(
          key: const Uuid().v4(),
          uid: LocalUser().getUserData().uid ?? "",
          name: nameController.text,
        );

    is_update ? updateCategory(category) : createCategory(category);
  }

  /// ✅ Create a new category
  void createCategory(CategoryEntity category) {
    CategoryService().addCategoryData(
      category: category,
      voidCallBack: (_) {
        refreshListView();
        Loader.showSuccess("تم الإنشاء بنجاح");
      },
    );
  }

  /// ✅ Update an existing category
  void updateCategory(CategoryEntity category) {
    CategoryService().updateCategoryData(
      category: category,
      voidCallBack: (_) {
        refreshListView();
        Loader.showSuccess("تم التحديث بنجاح");
      },
    );
  }

  /// ✅ Refresh category list after create/update
  void refreshListView() {
    final categoryVM = initController(() => CategoryViewModel());
    categoryVM.getData();
    categoryVM.update();
    Get.back();
  }

  /// ✅ Validation function
  bool validateStep() {
    return nameController.text.isNotEmpty;
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}
