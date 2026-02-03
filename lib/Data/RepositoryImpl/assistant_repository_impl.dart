import 'package:dartz/dartz.dart';

import '../../index/index_main.dart';

class AssistantRepositoryImpl extends AssistantRepository {
  final AssistantDataSourceRepo _assistantDataSourceRepo;

  AssistantRepositoryImpl(this._assistantDataSourceRepo);

  @override
  Future<Either<AppError, List<AssistantModel?>>> getAssistantsDomain(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      ) async {
    try {
      final result = await _assistantDataSourceRepo.getAssistants(data, query, isFiltered);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> addAssistantDomain(
      Map<String, dynamic> data,
      String key,
      ) async {
    try {
      final result = await _assistantDataSourceRepo.addAssistant(data, key);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> deleteAssistantDomain(
      Map<String, dynamic> data,
      String key,
      ) async {
    try {
      final result = await _assistantDataSourceRepo.deleteAssistant(data, key);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> updateAssistantDomain(
      Map<String, dynamic> data,
      String key,
      ) async {
    try {
      final result = await _assistantDataSourceRepo.updateAssistant(data, key);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }
}
