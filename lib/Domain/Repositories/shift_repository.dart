import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

abstract class ShiftRepository {
  /// 🔹 Get Shifts (Local First / Force Online)
  Future<Either<AppError, List<ShiftModel?>>> getShiftsDomain(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered, {
    bool? fromOnline,
  });

  /// 🩺 Get shifts for a specific doctor (for patient view)
  Future<Either<AppError, List<ShiftModel?>>> getShiftssFromPatientDomain(
    Map<String, dynamic> data,
    String? doctorKey,
  );

  /// 🔹 Add Shift
  Future<Either<AppError, SuccessModel>> addShiftDomain(
    Map<String, dynamic> data,
    String key,
  );

  /// 🔹 Delete Shift
  Future<Either<AppError, SuccessModel>> deleteShiftDomain(
    Map<String, dynamic> data,
    String key,
  );

  /// 🔹 Update Shift
  Future<Either<AppError, SuccessModel>> updateShiftDomain(
    Map<String, dynamic> data,
    String key,
  );
}
