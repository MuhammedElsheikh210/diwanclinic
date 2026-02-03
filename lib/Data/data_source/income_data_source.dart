import '../../index/index_main.dart';

abstract class IncomeDataSourceRepo {
  Future<List<IncomeModel?>> getIncomes(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  );

  Future<SuccessModel> addIncome(Map<String, dynamic> data, String key);

  Future<SuccessModel> deleteIncome(Map<String, dynamic> data, String key);

  Future<SuccessModel> updateIncome(Map<String, dynamic> data, String key);
}
