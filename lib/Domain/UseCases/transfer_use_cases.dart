import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class TransferUseCases {
  final TransferRepository _repository;

  TransferUseCases(this._repository);

  Future<Either<AppError, SuccessModel>> addTransfer(TransferModel transfer) {
    return _repository.addTransferMoneyDomain(transfer.toJson(), transfer.key ?? "");
  }

  Future<Either<AppError, SuccessModel>> updateTransfer(TransferModel transfer) {
    return _repository.updateTransferMoneyDomain(transfer.toJson(), transfer.key ?? "");
  }

  Future<Either<AppError, SuccessModel>> deleteTransfer(String key) {
    return _repository.deleteTransferMoneyDomain({}, key);
  }

  Future<Either<AppError, List<TransferModel?>>> getTransfers(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      ) {
    return _repository.getTransferMoneyDomain(data, query, isFiltered);
  }
}
