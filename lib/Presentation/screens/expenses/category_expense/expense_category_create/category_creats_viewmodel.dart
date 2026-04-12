import '../../../../../index/index_main.dart';

class CreateExpenseCategoryViewModel extends GetxController {
  /// Controllers for input fields
  final TextEditingController nameController = TextEditingController();
  List<GenericListModel> categoryTypeList = [
    GenericListModel(id: 0, key: "fixed", name: "ثابت"),
    GenericListModel(id: 1, key: "monthly", name: "شهري"),
  ];

  GenericListModel? selectedCategoryType;

  bool is_update = false;
  CategoryEntity? existingCategory;

  @override
  Future<void> onInit() async {
    super.onInit();
  }

  void populateFields(CategoryEntity category) {
    nameController.text = category.name ?? "";

    // ✅ Set the dropdown selected value from existing categoryType
    selectedCategoryType = categoryTypeList.firstWhere(
      (item) => item.key == category.categoryType,
      orElse: () => categoryTypeList.first,
    );

    is_update = true;
    update();
  }

  /// ✅ Save or update the category
  void saveCategory() {
    final category =
        existingCategory?.copyWith(
          name: nameController.text,
          categoryType: selectedCategoryType?.key, // Add this line
        ) ??
        CategoryEntity(
          key: const Uuid().v4(),
          uid: Get.find<UserSession>().user?.uid ?? "",
          name: nameController.text,
          categoryType: selectedCategoryType?.key,
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
    final categoryVM = initController(() => CategoryExpenseViewModel());
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
