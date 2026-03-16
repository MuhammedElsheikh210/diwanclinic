import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

class ShiftRepositoryImpl extends ShiftRepository {
  final ShiftDataSourceRepo _shiftDataSourceRepo;

  ShiftRepositoryImpl(this._shiftDataSourceRepo);

  /// 🕒 Get shifts for doctor
  @override
  Future<Either<AppError, List<ShiftModel?>>> getShiftsDomain(
      Map<String, dynamic> data,
      String? doctorKey,
      ) async {
    try {
      final result = await _shiftDataSourceRepo.getShifts(
        data,
        doctorKey,
      );

      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  /// 👩‍⚕️ Get shifts for patient view
  @override
  Future<Either<AppError, List<ShiftModel?>>> getShiftsFromPatientDomain(
      Map<String, dynamic> data,
      String? doctorKey,
      ) async {
    try {
      final result = await _shiftDataSourceRepo.getShiftsFromPatient(
        data,
        doctorKey,
      );

      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  /// ➕ Add shift
  @override
  Future<Either<AppError, SuccessModel>> addShiftDomain(
      Map<String, dynamic> data,
      String key,
      String? doctorKey,
      ) async {
    try {
      final result = await _shiftDataSourceRepo.addShift(
        data,
        key,
        doctorKey,
      );

      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  /// ❌ Delete shift
  @override
  Future<Either<AppError, SuccessModel>> deleteShiftDomain(
      Map<String, dynamic> data,
      String key,
      String? doctorKey,
      ) async {
    try {
      final result = await _shiftDataSourceRepo.deleteShift(
        data,
        key,
        doctorKey,
      );

      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  /// ✏️ Update shift
  @override
  Future<Either<AppError, SuccessModel>> updateShiftDomain(
      Map<String, dynamic> data,
      String key,
      String? doctorKey,
      ) async {
    try {
      final result = await _shiftDataSourceRepo.updateShift(
        data,
        key,
        doctorKey,
      );

      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }
}