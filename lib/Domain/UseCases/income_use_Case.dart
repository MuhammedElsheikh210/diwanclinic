import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class IncomeUseCases {
  final IncomeRepository _repository;

  IncomeUseCases(this._repository);

  Future<Either<AppError, SuccessModel>> addIncome(IncomeModel income) {
    return _repository.addIncomeDomain(income.toJson(), income.key ?? "");
  }

  Future<Either<AppError, SuccessModel>> updateIncome(IncomeModel income) {
    return _repository.updateIncomeDomain(income.toJson(), income.key ?? "");
  }

  Future<Either<AppError, SuccessModel>> deleteIncome(String key) {
    return _repository.deleteIncomeDomain({}, key);
  }

  Future<Either<AppError, List<IncomeModel?>>> getIncomes(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  ) {
    return _repository.getIncomesDomain(data, query, isFiltered);
  }
}
