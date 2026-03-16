import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class ShiftUseCases {
  final ShiftRepository _repository;

  ShiftUseCases(this._repository);

  /// 🕒 Add new shift
  Future<Either<AppError, SuccessModel>> addShift(ShiftModel shift) {
    return _repository.addShiftDomain(
      shift.toJson(),
      shift.key ?? "",
      shift.doctorKey,
    );
  }

  /// 🕒 Update existing shift
  Future<Either<AppError, SuccessModel>> updateShift(ShiftModel shift) {
    return _repository.updateShiftDomain(
      shift.toJson(),
      shift.key ?? "",
      shift.doctorKey,
    );
  }

  /// 🗑️ Delete shift
  Future<Either<AppError, SuccessModel>> deleteShift(
      String key,
      String? doctorKey,
      ) {
    return _repository.deleteShiftDomain(
      {},
      key,
      doctorKey,
    );
  }

  /// 📅 Get shifts for doctor
  Future<Either<AppError, List<ShiftModel?>>> getShifts(
      Map<String, dynamic> data,
      String? doctorKey,
      ) {
    return _repository.getShiftsDomain(
      data,
      doctorKey,
    );
  }

  /// 👩‍⚕️ Get shifts for patient
  Future<Either<AppError, List<ShiftModel?>>> getShiftsFromPatient(
      Map<String, dynamic> data,
      String? doctorKey,
      ) {
    return _repository.getShiftsFromPatientDomain(
      data,
      doctorKey,
    );
  }
}