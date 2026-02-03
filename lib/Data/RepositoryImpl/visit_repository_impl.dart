import 'package:dartz/dartz.dart';
import 'package:diwanclinic/Data/data_source/visit_data_source_repo.dart';
import 'package:diwanclinic/Domain/Repositories/visit_repository.dart';
import '../../index/index_main.dart';

class VisitRepositoryImpl extends VisitRepository {
  final VisitDataSourceRepo _visitDataSourceRepo;

  VisitRepositoryImpl(this._visitDataSourceRepo);

  @override
  Future<Either<AppError, List<VisitModel?>>> getVisitsDomain(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      ) async {
    try {
      final result = await _visitDataSourceRepo.getVisits(
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
  Future<Either<AppError, VisitModel>> getVisitDomain(
      Map<String, dynamic> data,
      ) async {
    try {
      final result = await _visitDataSourceRepo.getVisit(data);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> addVisitDomain(
      Map<String, dynamic> data,
      String id,
      ) async {
    try {
      final result = await _visitDataSourceRepo.addVisit(data, id);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> deleteVisitDomain(
      Map<String, dynamic> data,
      String id,
      ) async {
    try {
      final result = await _visitDataSourceRepo.deleteVisit(data, id);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> updateVisitDomain(
      Map<String, dynamic> data,
      String id,
      ) async {
    try {
      final result = await _visitDataSourceRepo.updateVisit(data, id);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }
}
