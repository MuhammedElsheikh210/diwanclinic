import '../../../../../index/index_main.dart';

class SpecializationViewModel extends GetxController {
  List<CategoryEntity?>? listCategories;
  List<String> priorityKeys = [
    "d5508360-6780-4a1a-91c2-3b419c0fbdd3", // أطفال
    "d66efe20-81a5-4df7-b6fb-07e5eae85465", // نساء وتوليد
    "f9a3b6bf-c5db-4592-85c6-f14bc59fb0dd", // جلدية
    // "xxxxx" جراحة ← ضيف لي key الجراحة لو موجود
    "a92f4b3e-998b-4cb9-9d8c-ff924ba2c77b", // باطنة
    "aa950b98-f49f-4290-ab82-bd1e8fbab411", // عظام
    "c09e07c9-ced7-4c1d-8e2b-47834e205d39", // أنف وأذن وحنجرة
    "c27f91dd-0b5f-4b6d-9c55-0b1cd8e01409", // مخ وأعصاب
  ];

  @override
  Future<void> onInit() async {
    getData();
    super.onInit();
  }

  /// ✅ Fetch Categories from API
  void getData() {
    CategoryService().getAllCategoriesData(
      voidCallBack: (data) {
        // ضع القائمة الأصلية
        listCategories = data;

        // ⭐ ترتيب بالتخصصات المهمة أولاً
        listCategories!.sort((a, b) {
          final aIndex = priorityKeys.indexOf(a?.key ?? "");
          final bIndex = priorityKeys.indexOf(b?.key ?? "");

          // لو الاثنين داخل الأولويات → رتب حسب مكانهم
          if (aIndex != -1 && bIndex != -1) {
            return aIndex.compareTo(bIndex);
          }

          // لو التخصص A مهم و B غير مهم → A أول
          if (aIndex != -1 && bIndex == -1) {
            return -1;
          }

          // لو التخصص B مهم و A غير مهم → B أول
          if (bIndex != -1 && aIndex == -1) {
            return 1;
          }

          // لو الاثنين غير مهمين → رتب بالاسم عادي
          return (a?.name ?? "").compareTo(b?.name ?? "");
        });

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
