import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class DeleteTransactionUseCase
    extends Use_Case<Either<AppError, SuccessModel>, String> {
  final TransactionsRepository _transactionsRepository;

  DeleteTransactionUseCase(this._transactionsRepository);

  @override
  Future<Either<AppError, SuccessModel>> call(String key) async {
    try {
      final result = await _transactionsRepository.deleteTransactionDomain({}, key);
      return result;
    } catch (error) {
      return Left(AppError(error.toString()));
    }
  }
}
