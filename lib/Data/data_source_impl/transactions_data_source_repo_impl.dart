import '../../index/index_main.dart';

class TransactionsDataSourceRepoImpl extends TransactionsDataSourceRepo {
  final ClientSourceRepo _clientSourceRepo;
  final BaseSQLiteDataSourceRepo<TransactionsModel> _sqliteRepo;

  TransactionsDataSourceRepoImpl(this._clientSourceRepo)
    : _sqliteRepo = BaseSQLiteDataSourceRepo<TransactionsModel>(
        tableName: "transactions",
        fromJson: (json) => TransactionsModel.fromJson(json),
        toJson: (model) => model.toJson(),
        getId: (model) => model.key,
      );

  /// ✅ Fetch all transactions with SQLite fallback and remote fetching support.
  @override
  Future<List<TransactionsModel?>> getTransactions(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  ) async {
    try {
      // ✅ Fetch from SQLite first
      print("query is $query");
      final sqliteData = await _sqliteRepo.getAll(query: query);

      if (sqliteData.isNotEmpty || (sqliteData.isEmpty && isFiltered == true)) {
        return sqliteData;
      }
    } catch (e) {}

    try {
      // ✅ Fetch from server if not found in SQLite
      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        "/${ApiConstatns.transactions}.json",
        params: data,
      );

      List<TransactionsModel?> transactionsList =
          handleResponse<TransactionsModel>(
            response,
            (json) => TransactionsModel.fromJson(json),
          );

      // ✅ Save each fetched transaction to SQLite directly (no batch operation)
      for (final transaction in transactionsList) {
        if (transaction != null &&
            transaction.key != null &&
            transaction.key!.isNotEmpty) {
          try {
            await _sqliteRepo.addItem(transaction);
          } catch (e) {}
        }
      }

      return transactionsList;
    } catch (e) {
      return []; // Return an empty list on failure
    }
  }

  /// ✅ Add a single transaction to SQLite and Firebase.
  @override
  Future<SuccessModel> addTransaction(
    Map<String, dynamic> data,
    String key,
  ) async {
    final transaction = TransactionsModel.fromJson(data);
    await _sqliteRepo.addItem(transaction);

    final response = await _clientSourceRepo.request(
      HttpMethod.PATCH,
      "/${ApiConstatns.transactions}/$key.json",
      params: data,
    );

    return SuccessModel.fromJson(response);
  }

  /// ✅ Delete a transaction from SQLite and Firebase.
  @override
  Future<SuccessModel> deleteTransaction(
    Map<String, dynamic> data,
    String key,
  ) async {
    await _sqliteRepo.deleteItem(key);

    final response = await _clientSourceRepo.request(
      HttpMethod.DELETE,
      "/${ApiConstatns.transactions}/$key.json",
      params: data,
    );

    return SuccessModel.fromJson(response ?? {"message": "تمت العملية بنجاح"});
  }

  /// ✅ Update a transaction in SQLite and Firebase.
  @override
  Future<SuccessModel> updateTransaction(
    Map<String, dynamic> data,
    String key,
  ) async {
    final transaction = TransactionsModel.fromJson(data);
    await _sqliteRepo.updateItem(transaction);

    final response = await _clientSourceRepo.request(
      HttpMethod.PATCH,
      "/${ApiConstatns.transactions}/$key.json",
      params: data,
    );

    return SuccessModel.fromJson(response);
  }
}
