import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class AddTransactionUseCase
    extends Use_Case<Either<AppError, SuccessModel>, TransactionsEntity> {
  final TransactionsRepository _transactionsRepository;

  AddTransactionUseCase(this._transactionsRepository);

  @override
  Future<Either<AppError, SuccessModel>> call(TransactionsEntity params) async {
    try {
      final result = await _transactionsRepository.addTransactionDomain(
        params.toJson(),
        params.key ?? "",
      );
      return result;
    } catch (error) {
      return Left(AppError(error.toString()));
    }
  }
}
