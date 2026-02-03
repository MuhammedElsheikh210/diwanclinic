import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

abstract class IncomeRepository {
  Future<Either<AppError, List<IncomeModel?>>> getIncomesDomain(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      );

  Future<Either<AppError, SuccessModel>> addIncomeDomain(
      Map<String, dynamic> data,
      String key,
      );

  Future<Either<AppError, SuccessModel>> deleteIncomeDomain(
      Map<String, dynamic> data,
      String key,
      );

  Future<Either<AppError, SuccessModel>> updateIncomeDomain(
      Map<String, dynamic> data,
      String key,
      );
}
