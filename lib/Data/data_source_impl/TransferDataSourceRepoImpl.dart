import 'package:diwanclinic/Data/data_source/transfer_data_source.dart';

import '../../index/index_main.dart';

class TransferDataSourceRepoImpl extends TransferDataSourceRepo {
  final ClientSourceRepo _clientSourceRepo;
  final BaseSQLiteDataSourceRepo<TransferModel> _sqliteRepo;

  TransferDataSourceRepoImpl(this._clientSourceRepo)
      : _sqliteRepo = BaseSQLiteDataSourceRepo<TransferModel>(
    tableName: "transfers",
    fromJson: (json) => TransferModel.fromJson(json),
    toJson: (model) => model.toJson(),
    getId: (model) => model.key,
  );

  @override
  Future<List<TransferModel?>> getTransferMoney(
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
        "/${ApiConstatns.transfers}.json",
        params: data,
      );

      List<TransferModel?> transferList = handleResponse<TransferModel>(
        response,
            (json) => TransferModel.fromJson(json),
      );

      for (final transfer in transferList) {
        if (transfer?.key?.isNotEmpty == true) {
          await _sqliteRepo.addItem(transfer!);
        }
      }

      return transferList;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<SuccessModel> addTransferMoney(Map<String, dynamic> data, String key) async {
    final transfer = TransferModel.fromJson(data);
    await _sqliteRepo.addItem(transfer);

    final response = await _clientSourceRepo.request(
      HttpMethod.PATCH,
      "/${ApiConstatns.transfers}/$key.json",
      params: data,
    );

    return SuccessModel.fromJson(response);
  }

  @override
  Future<SuccessModel> deleteTransferMoney(Map<String, dynamic> data, String key) async {
    await _sqliteRepo.deleteItem(key);

    final response = await _clientSourceRepo.request(
      HttpMethod.DELETE,
      "/${ApiConstatns.transfers}/$key.json",
      params: data,
    );

    return SuccessModel.fromJson(response ?? {"message": "تمت العملية بنجاح"});
  }

  @override
  Future<SuccessModel> updateTransferMoney(Map<String, dynamic> data, String key) async {
    final transfer = TransferModel.fromJson(data);
    await _sqliteRepo.updateItem(transfer);

    final response = await _clientSourceRepo.request(
      HttpMethod.PATCH,
      "/${ApiConstatns.transfers}/$key.json",
      params: data,
    );

    return SuccessModel.fromJson(response);
  }
}
