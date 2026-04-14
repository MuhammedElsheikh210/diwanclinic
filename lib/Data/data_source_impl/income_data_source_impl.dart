import '../../index/index_main.dart';

class IncomeDataSourceRepoImpl extends IncomeDataSourceRepo {
  final ClientSourceRepo _clientSourceRepo;
  final BaseSQLiteDataSourceRepo<IncomeModel> _sqliteRepo;

  IncomeDataSourceRepoImpl(this._clientSourceRepo)
    : _sqliteRepo = BaseSQLiteDataSourceRepo<IncomeModel>(
        tableName: "income_model",
        fromJson: (json) => IncomeModel.fromJson(json),
        toJson: (model) => model.toJson(),
        getId: (model) => model.key,
        idColumn: "key",
      );

  @override
  Future<List<IncomeModel?>> getIncomes(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  ) async {
    try {
      final sqliteData = await _sqliteRepo.getAll(query: query);
      if (sqliteData.isNotEmpty || (sqliteData.isEmpty && isFiltered == true)) {
        return sqliteData;
      }
    } catch (_) {}

    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        "/${ApiConstatns.income_model}.json",
        params: data,
      );

      List<IncomeModel?> incomeList = handleResponse<IncomeModel>(
        response,
        (json) => IncomeModel.fromJson(json),
      );

      for (final income in incomeList) {
        if (income?.key?.isNotEmpty == true) {
          await _sqliteRepo.addItem(income!);
        }
      }

      return incomeList;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<SuccessModel> addIncome(Map<String, dynamic> data, String key) async {
    final income = IncomeModel.fromJson(data);
    await _sqliteRepo.addItem(income);

    final response = await _clientSourceRepo.request(
      HttpMethod.PATCH,
      "/${ApiConstatns.income_model}/$key.json",
      params: data,
    );

    return SuccessModel.fromJson(response);
  }

  @override
  Future<SuccessModel> deleteIncome(
    Map<String, dynamic> data,
    String key,
  ) async {
    await _sqliteRepo.deleteItem(key);

    final response = await _clientSourceRepo.request(
      HttpMethod.DELETE,
      "/${ApiConstatns.income_model}/$key.json",
      params: data,
    );

    return SuccessModel.fromJson(response ?? {"message": "تمت العملية بنجاح"});
  }

  @override
  Future<SuccessModel> updateIncome(
    Map<String, dynamic> data,
    String key,
  ) async {
    final income = IncomeModel.fromJson(data);
    await _sqliteRepo.updateItem(income);

    final response = await _clientSourceRepo.request(
      HttpMethod.PATCH,
      "/${ApiConstatns.income_model}/$key.json",
      params: data,
    );

    return SuccessModel.fromJson(response);
  }
}
