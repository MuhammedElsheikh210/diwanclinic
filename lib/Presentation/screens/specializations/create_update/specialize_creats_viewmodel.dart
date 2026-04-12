import '../../../../../index/index_main.dart';

class CreateSpecializeViewModel extends GetxController {
  /// Controllers for input fields
  final TextEditingController nameController = TextEditingController();

  bool is_update = false;
  CategoryEntity? existingCategory;

  @override
  Future<void> onInit() async {
    nameController.addListener(() => update());
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
    final user = Get.find<UserSession>().user;

    final category =
        existingCategory?.copyWith(name: nameController.text) ??
        CategoryEntity(
          key: const Uuid().v4(),
          uid: user?.uid ?? "",
          icon_name: "heartPulse",
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
    final categoryVM = initController(() => SpecializationViewModel());
    categoryVM.getData();
    categoryVM.update();
    Get.back();
  }

  /// ✅ Validation function
  bool validateStep() {
    print("checcck is ${nameController.text.isNotEmpty}");
    return nameController.text.isNotEmpty;
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}
