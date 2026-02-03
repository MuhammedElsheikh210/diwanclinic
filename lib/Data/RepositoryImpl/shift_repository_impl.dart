import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

class ShiftRepositoryImpl extends ShiftRepository {
  final ShiftDataSourceRepo _shiftDataSourceRepo;

  ShiftRepositoryImpl(this._shiftDataSourceRepo);

  @override
  Future<Either<AppError, List<ShiftModel?>>> getShiftsDomain(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      ) async {
    try {
      final result = await _shiftDataSourceRepo.getShifts(
        data,
        query,
        isFiltered,
      );
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  /// 👩‍⚕️ Get shifts for a specific doctor (for patient view)
  @override
  Future<Either<AppError, List<ShiftModel?>>> getShiftssFromPatientDomain(
      Map<String, dynamic> data,
      String? doctorKey,
      ) async {
    try {
      final result = await _shiftDataSourceRepo.getShiftssFromPatient(
        data,
        doctorKey,
      );
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> addShiftDomain(
      Map<String, dynamic> data,
      String key,
      ) async {
    try {
      final result = await _shiftDataSourceRepo.addShift(data, key);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> deleteShiftDomain(
      Map<String, dynamic> data,
      String key,
      ) async {
    try {
      final result = await _shiftDataSourceRepo.deleteShift(data, key);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> updateShiftDomain(
      Map<String, dynamic> data,
      String key,
      ) async {
    try {
      final result = await _shiftDataSourceRepo.updateShift(data, key);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }
}
