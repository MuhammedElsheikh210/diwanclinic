import 'package:sqflite/sql.dart';
import '../../index/index_main.dart';

class CategoryDataSourceRepoImpl extends CategoryDataSourceRepo {
  final ClientSourceRepo _clientSourceRepo;
  // final BaseSQLiteDataSourceRepo<CategoryModel> _sqliteRepo;

  CategoryDataSourceRepoImpl(this._clientSourceRepo)
  /*: _sqliteRepo = BaseSQLiteDataSourceRepo<CategoryModel>(
          tableName: "specializations",
          fromJson: (json) => CategoryModel.fromJson(json),
          toJson: (model) => model.toJson(),
          getId: (model) => model.key,
        )*/;

  @override
  Future<List<CategoryModel?>> getCategories(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      ) async {
    try {
      // 🔸 Local fetch (disabled)
      // final sqliteData = await _sqliteRepo.getAll(query: query);
      // if (sqliteData.isNotEmpty || (sqliteData.isEmpty && isFiltered == true)) {
      //   return sqliteData;
      // }
    } catch (e) {
      print("❌ [ERROR] - Fetching Categories from SQLite failed: $e");
    }

    try {
      // 🔹 Online fetch
      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        "/${ApiConstatns.specializations}.json",
        params: data,
      );

      List<CategoryModel?> categoryList = handleResponse<CategoryModel>(
        response,
            (json) => CategoryModel.fromJson(json),
      );

      // 🔸 Save to local (disabled)
      // for (final category in categoryList) {
      //   if (category?.key?.isNotEmpty == true) {
      //     await _sqliteRepo.addItem(category!);
      //   }
      // }

      return categoryList;
    } catch (e) {
      print("❌ Remote fetch failed: $e");
      return [];
    }
  }

  @override
  Future<CategoryModel> getCategory(Map<String, dynamic> data) async {
    try {
      // 🔸 Local get (disabled)
      // final key = data['key'] as String;
      // final localCategory = await _sqliteRepo.getItem(key);
      // if (localCategory != null) return localCategory;
    } catch (_) {}

    // 🔹 Online get
    final response = await _clientSourceRepo.request(
      HttpMethod.GET,
      "/${ApiConstatns.specializations}.json",
      params: data,
    );
    final categoryJson = response.values.first as Map<String, dynamic>;
    final category = CategoryModel.fromJson(categoryJson);

    // 🔸 Save to local (disabled)
    // if (category.key != null) {
    //   await _sqliteRepo.addItem(category);
    // }

    return category;
  }

  @override
  Future<SuccessModel> addCategory(Map<String, dynamic> data, String id) async {
    final model = CategoryModel.fromJson(data);

    // 🔸 Local add (disabled)
    // await _sqliteRepo.addItem(model);

    // 🔹 Online add
    final response = await _clientSourceRepo.request(
      HttpMethod.PATCH,
      "/${ApiConstatns.specializations}/$id.json",
      params: data,
    );

    return SuccessModel.fromJson(response);
  }

  @override
  Future<SuccessModel> deleteCategory(
      Map<String, dynamic> data,
      String id,
      ) async {
    // 🔸 Local delete (disabled)
    // await _sqliteRepo.deleteItem(id);

    // 🔹 Online delete
    final response = await _clientSourceRepo.request(
      HttpMethod.DELETE,
      "/${ApiConstatns.specializations}/$id.json",
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
    final model = CategoryModel.fromJson(data);

    // 🔸 Local update (disabled)
    // await _sqliteRepo.updateItem(model);

    // 🔹 Online update
    final response = await _clientSourceRepo.request(
      HttpMethod.PATCH,
      "/${ApiConstatns.specializations}/$id.json",
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
      final List<Map<String, dynamic>> sqliteList = [];

      for (var category in data) {
        final key = category["key"] ?? const Uuid().v4();
        bulkData[key] = category;
        sqliteList.add(category);
      }

      // 🔸 Local bulk insert (disabled)
      // final db = await _sqliteRepo.db;
      // final batch = db.batch();
      // for (final item in sqliteList) {
      //   batch.insert(
      //     _sqliteRepo.tableName,
      //     item,
      //     conflictAlgorithm: ConflictAlgorithm.replace,
      //   );
      // }
      // await batch.commit(noResult: true);

      // 🔹 Online bulk update
      final response = await _clientSourceRepo.request(
        HttpMethod.PATCH,
        "/${ApiConstatns.specializations}.json",
        params: bulkData,
      );

      return SuccessModel.fromJson(response);
    } catch (e) {
      print("❌ Bulk insert failed: $e");
      return SuccessModel(message: "Bulk insertion failed");
    }
  }
}
