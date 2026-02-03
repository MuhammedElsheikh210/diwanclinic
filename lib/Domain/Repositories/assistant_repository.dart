import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

abstract class AssistantRepository {
  Future<Either<AppError, List<AssistantModel?>>> getAssistantsDomain(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      );

  Future<Either<AppError, SuccessModel>> addAssistantDomain(
      Map<String, dynamic> data,
      String key,
      );

  Future<Either<AppError, SuccessModel>> deleteAssistantDomain(
      Map<String, dynamic> data,
      String key,
      );

  Future<Either<AppError, SuccessModel>> updateAssistantDomain(
      Map<String, dynamic> data,
      String key,
      );
}
