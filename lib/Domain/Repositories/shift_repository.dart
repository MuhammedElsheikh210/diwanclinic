import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

abstract class ShiftRepository {
  Future<Either<AppError, List<ShiftModel?>>> getShiftsDomain(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      );

  /// 🩺 Get shifts for a specific doctor (for patient view)
  Future<Either<AppError, List<ShiftModel?>>> getShiftssFromPatientDomain(
      Map<String, dynamic> data,
      String? doctorKey,
      );

  Future<Either<AppError, SuccessModel>> addShiftDomain(
      Map<String, dynamic> data,
      String key,
      );

  Future<Either<AppError, SuccessModel>> deleteShiftDomain(
      Map<String, dynamic> data,
      String key,
      );

  Future<Either<AppError, SuccessModel>> updateShiftDomain(
      Map<String, dynamic> data,
      String key,
      );
}
