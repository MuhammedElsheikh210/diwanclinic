import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class DoctorSuggestionUseCases {
  final DoctorSuggestionRepository _repository;

  DoctorSuggestionUseCases(this._repository);

  /// 🔹 Add a new doctor suggestion
  Future<Either<AppError, SuccessModel>> addDoctorSuggestion(
      DoctorSuggestionModel suggestion) {
    return _repository.addDoctorSuggestionDomain(
      suggestion.toJson(),
      suggestion.key ?? "",
    );
  }

  /// 🔹 Update existing doctor suggestion
  Future<Either<AppError, SuccessModel>> updateDoctorSuggestion(
      DoctorSuggestionModel suggestion) {
    return _repository.updateDoctorSuggestionDomain(
      suggestion.toJson(),
      suggestion.key ?? "",
    );
  }

  /// 🔹 Delete doctor suggestion by key
  Future<Either<AppError, SuccessModel>> deleteDoctorSuggestion(String key) {
    return _repository.deleteDoctorSuggestionDomain({}, key);
  }

  /// 🔹 Get all doctor suggestions
  Future<Either<AppError, List<DoctorSuggestionModel?>>> getDoctorSuggestions(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      ) {
    return _repository.getDoctorSuggestionsDomain(data, query, isFiltered);
  }
}
