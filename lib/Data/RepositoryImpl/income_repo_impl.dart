import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

class IncomeRepositoryImpl extends IncomeRepository {
  final IncomeDataSourceRepo _incomeDataSourceRepo;

  IncomeRepositoryImpl(this._incomeDataSourceRepo);

  @override
  Future<Either<AppError, List<IncomeModel?>>> getIncomesDomain(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      ) async {
    try {
      final result = await _incomeDataSourceRepo.getIncomes(data, query, isFiltered);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> addIncomeDomain(
      Map<String, dynamic> data,
      String key,
      ) async {
    try {
      final result = await _incomeDataSourceRepo.addIncome(data, key);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> deleteIncomeDomain(
      Map<String, dynamic> data,
      String key,
      ) async {
    try {
      final result = await _incomeDataSourceRepo.deleteIncome(data, key);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> updateIncomeDomain(
      Map<String, dynamic> data,
      String key,
      ) async {
    try {
      final result = await _incomeDataSourceRepo.updateIncome(data, key);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }
}
