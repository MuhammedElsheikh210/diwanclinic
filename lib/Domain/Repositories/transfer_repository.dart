import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

abstract class TransferRepository {
  Future<Either<AppError, List<TransferModel?>>> getTransferMoneyDomain(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      );

  Future<Either<AppError, SuccessModel>> addTransferMoneyDomain(
      Map<String, dynamic> data,
      String key,
      );

  Future<Either<AppError, SuccessModel>> deleteTransferMoneyDomain(
      Map<String, dynamic> data,
      String key,
      );

  Future<Either<AppError, SuccessModel>> updateTransferMoneyDomain(
      Map<String, dynamic> data,
      String key,
      );
}
