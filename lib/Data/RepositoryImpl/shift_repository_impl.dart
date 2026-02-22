import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

class ShiftRepositoryImpl extends ShiftRepository {
  final ShiftDataSourceRepo _shiftDataSourceRepo;

  ShiftRepositoryImpl(this._shiftDataSourceRepo);

  // =========================================================
  // 🔹 GET SHIFTS
  // =========================================================
  @override
  Future<Either<AppError, List<ShiftModel?>>> getShiftsDomain(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered, {
    bool? fromOnline,
  }) async {
    try {
      final result = await _shiftDataSourceRepo.getShifts(
        data,
        query,
        isFiltered,
        fromOnline: fromOnline,
      );

      return Right(result);
    } catch (e, stack) {
      print("❌ ShiftRepositoryImpl.getShiftsDomain: $e");
      print(stack);
      return Left(AppError(e.toString()));
    }
  }

  // =========================================================
  // 🔹 GET SHIFTS FROM PATIENT
  // =========================================================
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
    } catch (e, stack) {
      print("❌ ShiftRepositoryImpl.getShiftssFromPatientDomain: $e");
      print(stack);
      return Left(AppError(e.toString()));
    }
  }

  // =========================================================
  // 🔹 ADD SHIFT
  // =========================================================
  @override
  Future<Either<AppError, SuccessModel>> addShiftDomain(
    Map<String, dynamic> data,
    String key,
  ) async {
    try {
      final result = await _shiftDataSourceRepo.addShift(data, key);
      return Right(result);
    } catch (e, stack) {
      print("❌ ShiftRepositoryImpl.addShiftDomain: $e");
      print(stack);
      return Left(AppError(e.toString()));
    }
  }

  // =========================================================
  // 🔹 DELETE SHIFT
  // =========================================================
  @override
  Future<Either<AppError, SuccessModel>> deleteShiftDomain(
    Map<String, dynamic> data,
    String key,
  ) async {
    try {
      final result = await _shiftDataSourceRepo.deleteShift(data, key);
      return Right(result);
    } catch (e, stack) {
      print("❌ ShiftRepositoryImpl.deleteShiftDomain: $e");
      print(stack);
      return Left(AppError(e.toString()));
    }
  }

  // =========================================================
  // 🔹 UPDATE SHIFT
  // =========================================================
  @override
  Future<Either<AppError, SuccessModel>> updateShiftDomain(
    Map<String, dynamic> data,
    String key,
  ) async {
    try {
      final result = await _shiftDataSourceRepo.updateShift(data, key);
      return Right(result);
    } catch (e, stack) {
      print("❌ ShiftRepositoryImpl.updateShiftDomain: $e");
      print(stack);
      return Left(AppError(e.toString()));
    }
  }
}
