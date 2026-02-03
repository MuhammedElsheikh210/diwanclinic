import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

abstract class FilesRepository {
  Future<Either<AppError, List<FilesModel?>>> getFilesDomain(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      );

  Future<Either<AppError, SuccessModel>> addFileDomain(
      Map<String, dynamic> data,
      String key,
      );

  Future<Either<AppError, SuccessModel>> deleteFileDomain(
      Map<String, dynamic> data,
      String key,
      );

  Future<Either<AppError, SuccessModel>> updateFileDomain(
      Map<String, dynamic> data,
      String key,
      );
}
