import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class FilesUseCases {
  final FilesRepository _repository;

  FilesUseCases(this._repository);

  Future<Either<AppError, SuccessModel>> addFile(FilesModel file) {
    return _repository.addFileDomain(file.toJson(), file.key ?? "");
  }

  Future<Either<AppError, SuccessModel>> updateFile(FilesModel file) {
    return _repository.updateFileDomain(file.toJson(), file.key ?? "");
  }

  Future<Either<AppError, SuccessModel>> deleteFile(String key) {
    return _repository.deleteFileDomain({}, key);
  }

  Future<Either<AppError, List<FilesModel?>>> getFiles(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      ) {
    return _repository.getFilesDomain(data, query, isFiltered);
  }
}
