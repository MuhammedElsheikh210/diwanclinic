import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class GetAllTransactionsUseCase
    extends
        Use_Case<
          Either<AppError, List<TransactionsEntity?>>,
          SQLiteQueryParams
        > {
  final TransactionsRepository _transactionsRepository;

  GetAllTransactionsUseCase(this._transactionsRepository);

  @override
  Future<Either<AppError, List<TransactionsEntity?>>> call(
    SQLiteQueryParams params,
  ) async {
    try {
      final result = await _transactionsRepository.getTransactionsDomain(
        {},
        params,
        params.is_filtered,
      );
      return result;
    } catch (error) {
      return Left(AppError(error.toString()));
    }
  }
}
