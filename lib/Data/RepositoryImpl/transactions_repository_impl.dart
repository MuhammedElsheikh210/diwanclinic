import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

class TransactionsRepositoryImpl extends TransactionsRepository {
  final TransactionsDataSourceRepo _transactionsDataSourceRepo;

  TransactionsRepositoryImpl(this._transactionsDataSourceRepo);

  @override
  Future<Either<AppError, List<TransactionsEntity?>>> getTransactionsDomain(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      ) async {
    try {
      final result = await _transactionsDataSourceRepo.getTransactions(
        data,
        query,
        isFiltered,
      );
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }



  @override
  Future<Either<AppError, SuccessModel>> addTransactionDomain(
      Map<String, dynamic> data,
      String key,
      ) async {
    try {
      final result = await _transactionsDataSourceRepo.addTransaction(data, key);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> deleteTransactionDomain(
      Map<String, dynamic> data,
      String key,
      ) async {
    try {
      final result = await _transactionsDataSourceRepo.deleteTransaction(data, key);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> updateTransactionDomain(
      Map<String, dynamic> data,
      String key,
      ) async {
    try {
      final result = await _transactionsDataSourceRepo.updateTransaction(data, key);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }


}
