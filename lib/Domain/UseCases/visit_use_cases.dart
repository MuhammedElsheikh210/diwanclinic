import 'package:dartz/dartz.dart';
import 'package:diwanclinic/Domain/Repositories/visit_repository.dart';
import '../../../index/index_main.dart';

class VisitUseCases {
  final VisitRepository _repository;

  VisitUseCases(this._repository);

  /// ➕ Add a new visit
  Future<Either<AppError, SuccessModel>> addVisit(VisitModel visit) {
    return _repository.addVisitDomain(visit.toJson(), visit.key ?? "");
  }

  /// 🔄 Update an existing visit
  Future<Either<AppError, SuccessModel>> updateVisit(VisitModel visit) {
    return _repository.updateVisitDomain(visit.toJson(), visit.key ?? "");
  }

  /// 🗑 Delete a visit
  Future<Either<AppError, SuccessModel>> deleteVisit(String key) {
    return _repository.deleteVisitDomain({}, key);
  }

  /// 🔍 Get all visits with optional filters
  Future<Either<AppError, List<VisitModel?>>> getVisits(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      ) {
    return _repository.getVisitsDomain(data, query, isFiltered);
  }

  /// 📌 Get a single visit
  Future<Either<AppError, VisitModel>> getVisit(Map<String, dynamic> data) {
    return _repository.getVisitDomain(data);
  }
}
