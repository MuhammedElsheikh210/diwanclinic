import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

class DoctorSuggestionRepositoryImpl extends DoctorSuggestionRepository {
  final DoctorSuggestionDataSourceRepo _doctorSuggestionDataSourceRepo;

  DoctorSuggestionRepositoryImpl(this._doctorSuggestionDataSourceRepo);

  @override
  Future<Either<AppError, List<DoctorSuggestionModel?>>> getDoctorSuggestionsDomain(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      ) async {
    try {
      final result = await _doctorSuggestionDataSourceRepo.getDoctorSuggestions(
        data,
        query,
        isFiltered,
      );
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> addDoctorSuggestionDomain(
      Map<String, dynamic> data,
      String key,
      ) async {
    try {
      final result = await _doctorSuggestionDataSourceRepo.addDoctorSuggestion(data, key);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> deleteDoctorSuggestionDomain(
      Map<String, dynamic> data,
      String key,
      ) async {
    try {
      final result = await _doctorSuggestionDataSourceRepo.deleteDoctorSuggestion(data, key);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> updateDoctorSuggestionDomain(
      Map<String, dynamic> data,
      String key,
      ) async {
    try {
      final result = await _doctorSuggestionDataSourceRepo.updateDoctorSuggestion(data, key);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }
}
