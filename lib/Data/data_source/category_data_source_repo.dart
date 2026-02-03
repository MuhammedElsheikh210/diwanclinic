import '../../index/index_main.dart';

abstract class CategoryDataSourceRepo {
  Future<List<CategoryModel?>> getCategories(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  );

  Future<CategoryModel> getCategory(Map<String, dynamic> data);

  Future<SuccessModel> addCategory(Map<String, dynamic> data, String id);

  Future<SuccessModel> deleteCategory(Map<String, dynamic> data, String id);

  Future<SuccessModel> updateCategory(Map<String, dynamic> data, String id);

  /// ✅ New Method for Bulk Insert
  Future<SuccessModel> addBulkCategories(List<Map<String, dynamic>> data);
}
