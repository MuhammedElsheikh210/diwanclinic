import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

abstract class ShiftRepository {

  /// 🕒 Get shifts for doctor
  Future<Either<AppError, List<ShiftModel?>>> getShiftsDomain(
      Map<String, dynamic> data,
      String? doctorKey,
      );

  /// 👨‍⚕️ Get shifts for patient view
  Future<Either<AppError, List<ShiftModel?>>> getShiftsFromPatientDomain(
      Map<String, dynamic> data,
      String? doctorKey,
      );

  /// ➕ Add shift
  Future<Either<AppError, SuccessModel>> addShiftDomain(
      Map<String, dynamic> data,
      String key,
      String? doctorKey,
      );

  /// ❌ Delete shift
  Future<Either<AppError, SuccessModel>> deleteShiftDomain(
      Map<String, dynamic> data,
      String key,
      String? doctorKey,
      );

  /// ✏️ Update shift
  Future<Either<AppError, SuccessModel>> updateShiftDomain(
      Map<String, dynamic> data,
      String key,
      String? doctorKey,
      );
}