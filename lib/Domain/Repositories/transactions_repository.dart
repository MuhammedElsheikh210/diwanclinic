import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

abstract class TransactionsRepository {
  /// Fetch a list of transactions with optional filtering and sorting.
  Future<Either<AppError, List<TransactionsEntity?>>> getTransactionsDomain(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  );



  /// Add a transaction.
  Future<Either<AppError, SuccessModel>> addTransactionDomain(
    Map<String, dynamic> data,
    String key,
  );

  /// Delete a transaction.
  Future<Either<AppError, SuccessModel>> deleteTransactionDomain(
    Map<String, dynamic> data,
    String key,
  );

  /// Update a transaction.
  Future<Either<AppError, SuccessModel>> updateTransactionDomain(
    Map<String, dynamic> data,
    String key,
  );
}
