import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class AssistantUseCases {
  final AssistantRepository _repository;

  AssistantUseCases(this._repository);

  Future<Either<AppError, SuccessModel>> addAssistant(AssistantModel assistant) {
    return _repository.addAssistantDomain(assistant.toJson(), assistant.key ?? "");
  }

  Future<Either<AppError, SuccessModel>> updateAssistant(AssistantModel assistant) {
    return _repository.updateAssistantDomain(assistant.toJson(), assistant.key ?? "");
  }

  Future<Either<AppError, SuccessModel>> deleteAssistant(String key) {
    return _repository.deleteAssistantDomain({}, key);
  }

  Future<Either<AppError, List<AssistantModel?>>> getAssistants(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      ) {
    return _repository.getAssistantsDomain(data, query, isFiltered);
  }
}
