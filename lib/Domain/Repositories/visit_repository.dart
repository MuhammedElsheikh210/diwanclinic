import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

abstract class VisitRepository {
  /// 🔍 Fetch a list of visits with optional filtering
  Future<Either<AppError, List<VisitModel?>>> getVisitsDomain(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      );

  /// 📌 Fetch a single visit
  Future<Either<AppError, VisitModel>> getVisitDomain(
      Map<String, dynamic> data,
      );

  /// ➕ Add a new visit
  Future<Either<AppError, SuccessModel>> addVisitDomain(
      Map<String, dynamic> data,
      String id,
      );

  /// 🗑 Delete a visit
  Future<Either<AppError, SuccessModel>> deleteVisitDomain(
      Map<String, dynamic> data,
      String id,
      );

  /// 🔄 Update an existing visit
  Future<Either<AppError, SuccessModel>> updateVisitDomain(
      Map<String, dynamic> data,
      String id,
      );
}
