import '../../../../index/index_main.dart';

/// Static class for handling model conversions for CategoryEntity
class CategoryModelAdapterUtil {
  /// Convert a single `CategoryEntity` to `GenericListModel`
  static GenericListModel convertCategoryToGeneric(CategoryEntity? category) {
    return GenericListModel(
      key: category?.key ?? "",
      name: category?.name ?? "Unnamed Category",
      category_type: category?.categoryType ?? ""
    );
  }

  /// Convert a list of `CategoryEntity` to a list of `GenericListModel`
  static List<GenericListModel> convertCategoryListToGeneric(
      List<CategoryEntity?> categoryList,
      ) {
    return categoryList
        .map((category) => convertCategoryToGeneric(category))
        .toList();
  }

  /// Find a category model in a list by key
  static CategoryEntity findCategoryByKey(List<CategoryEntity> list, String key) {
    try {
      return list.firstWhere(
            (category) => category.key == key,
        orElse: () => throw Exception('Category with key $key not found'),
      );
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
