import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

class TransferRepositoryImpl extends TransferRepository {
  final TransferDataSourceRepo _transferDataSourceRepo;

  TransferRepositoryImpl(this._transferDataSourceRepo);

  @override
  Future<Either<AppError, List<TransferModel?>>> getTransferMoneyDomain(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      ) async {
    try {
      final result = await _transferDataSourceRepo.getTransferMoney(data, query, isFiltered);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> addTransferMoneyDomain(
      Map<String, dynamic> data,
      String key,
      ) async {
    try {
      final result = await _transferDataSourceRepo.addTransferMoney(data, key);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> deleteTransferMoneyDomain(
      Map<String, dynamic> data,
      String key,
      ) async {
    try {
      final result = await _transferDataSourceRepo.deleteTransferMoney(data, key);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> updateTransferMoneyDomain(
      Map<String, dynamic> data,
      String key,
      ) async {
    try {
      final result = await _transferDataSourceRepo.updateTransferMoney(data, key);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }
}
