import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

abstract class DoctorSuggestionRepository {
  /// 🔹 Get all doctor suggestions (from domain)
  Future<Either<AppError, List<DoctorSuggestionModel?>>> getDoctorSuggestionsDomain(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      );

  /// 🔹 Add a new doctor suggestion (domain layer)
  Future<Either<AppError, SuccessModel>> addDoctorSuggestionDomain(
      Map<String, dynamic> data,
      String key,
      );

  /// 🔹 Delete an existing doctor suggestion (domain layer)
  Future<Either<AppError, SuccessModel>> deleteDoctorSuggestionDomain(
      Map<String, dynamic> data,
      String key,
      );

  /// 🔹 Update an existing doctor suggestion (domain layer)
  Future<Either<AppError, SuccessModel>> updateDoctorSuggestionDomain(
      Map<String, dynamic> data,
      String key,
      );
}
