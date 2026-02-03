import '../../index/index_main.dart';

abstract class TransactionsDataSourceRepo {
  Future<List<TransactionsModel?>> getTransactions(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  );


  Future<SuccessModel> addTransaction(Map<String, dynamic> data, String key);


  Future<SuccessModel> deleteTransaction(Map<String, dynamic> data, String key);

  Future<SuccessModel> updateTransaction(Map<String, dynamic> data, String key);
}
