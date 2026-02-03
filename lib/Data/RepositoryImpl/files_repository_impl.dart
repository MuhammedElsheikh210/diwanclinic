import 'package:dartz/dartz.dart';

import '../../index/index_main.dart';

class FilesRepositoryImpl extends FilesRepository {
  final FilesDataSourceRepo _filesDataSourceRepo;

  FilesRepositoryImpl(this._filesDataSourceRepo);

  @override
  Future<Either<AppError, List<FilesModel?>>> getFilesDomain(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      ) async {
    try {
      final result = await _filesDataSourceRepo.getFiles(data, query, isFiltered);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> addFileDomain(
      Map<String, dynamic> data,
      String key,
      ) async {
    try {
      final result = await _filesDataSourceRepo.addFile(data, key);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> deleteFileDomain(
      Map<String, dynamic> data,
      String key,
      ) async {
    try {
      final result = await _filesDataSourceRepo.deleteFile(data, key);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> updateFileDomain(
      Map<String, dynamic> data,
      String key,
      ) async {
    try {
      final result = await _filesDataSourceRepo.updateFile(data, key);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }
}
