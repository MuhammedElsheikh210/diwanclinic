import '../../index/index_main.dart';

class CategoryDataSourceRepoImpl extends CategoryDataSourceRepo {
  final ClientSourceRepo _clientSourceRepo;

  CategoryDataSourceRepoImpl(this._clientSourceRepo);

  /// ✅ Dynamic category path
  String _getCategoryPath(Map<String, dynamic> data) {
    final categoryType = data['categoryType'];

    if (categoryType == null || categoryType.toString().isEmpty) {
      return ApiConstatns.specializations;
    }

    return categoryType.toString();
  }

  @override
  Future<List<CategoryModel?>> getCategories(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  ) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        "/${_getCategoryPath(data)}.json",
        params: data,
      );

      List<CategoryModel?> categoryList = handleResponse<CategoryModel>(
        response,
        (json) => CategoryModel.fromJson(json),
      );

      return categoryList;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<CategoryModel> getCategory(Map<String, dynamic> data) async {
    final response = await _clientSourceRepo.request(
      HttpMethod.GET,
      "/${_getCategoryPath(data)}.json",
      params: data,
    );

    final categoryJson = response.values.first as Map<String, dynamic>;

    final category = CategoryModel.fromJson(categoryJson);

    return category;
  }

  @override
  Future<SuccessModel> addCategory(Map<String, dynamic> data, String id) async {
    final response = await _clientSourceRepo.request(
      HttpMethod.PATCH,
      "/${_getCategoryPath(data)}/$id.json",
      params: data,
    );

    return SuccessModel.fromJson(response);
  }

  @override
  Future<SuccessModel> deleteCategory(
    Map<String, dynamic> data,
    String id,
  ) async {
    final response = await _clientSourceRepo.request(
      HttpMethod.DELETE,
      "/${_getCategoryPath(data)}/$id.json",
      params: data,
    );

    return response == null
        ? SuccessModel(message: "تمت العملية بنجاح")
        : SuccessModel.fromJson(response);
  }

  @override
  Future<SuccessModel> updateCategory(
    Map<String, dynamic> data,
    String id,
  ) async {
    final response = await _clientSourceRepo.request(
      HttpMethod.PATCH,
      "/${_getCategoryPath(data)}/$id.json",
      params: data,
    );

    return SuccessModel.fromJson(response);
  }

  @override
  Future<SuccessModel> addBulkCategories(
    List<Map<String, dynamic>> data,
  ) async {
    try {
      final bulkData = <String, dynamic>{};

      String categoryPath = ApiConstatns.specializations;

      for (var category in data) {
        final key = category["key"] ?? const Uuid().v4();

        categoryPath = category['categoryType'] ?? ApiConstatns.specializations;

        bulkData[key] = category;
      }

      final response = await _clientSourceRepo.request(
        HttpMethod.PATCH,
        "/$categoryPath.json",
        params: bulkData,
      );

      return SuccessModel.fromJson(response);
    } catch (e) {
      return SuccessModel(message: "Bulk insertion failed");
    }
  }
}
