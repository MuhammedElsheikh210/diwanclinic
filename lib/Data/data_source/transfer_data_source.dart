
import '../../index/index_main.dart';

abstract class TransferDataSourceRepo {
  Future<List<TransferModel?>> getTransferMoney(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  );

  Future<SuccessModel> addTransferMoney(Map<String, dynamic> data, String key);

  Future<SuccessModel> deleteTransferMoney(
    Map<String, dynamic> data,
    String key,
  );

  Future<SuccessModel> updateTransferMoney(
    Map<String, dynamic> data,
    String key,
  );
}
