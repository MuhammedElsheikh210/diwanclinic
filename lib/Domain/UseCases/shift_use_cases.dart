import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class ShiftUseCases {
  final ShiftRepository _repository;

  ShiftUseCases(this._repository);

  /// 🕒 Add new shift
  Future<Either<AppError, SuccessModel>> addShift(ShiftModel shift) {
    return _repository.addShiftDomain(shift.toJson(), shift.key ?? "");
  }

  /// 🕒 Update existing shift
  Future<Either<AppError, SuccessModel>> updateShift(ShiftModel shift) {
    return _repository.updateShiftDomain(shift.toJson(), shift.key ?? "");
  }

  /// 🗑️ Delete shift
  Future<Either<AppError, SuccessModel>> deleteShift(String key) {
    return _repository.deleteShiftDomain({}, key);
  }

  /// 📅 Get all shifts
  Future<Either<AppError, List<ShiftModel?>>> getShifts(
      FirebaseFilter data,
      SQLiteQueryParams query,
      bool? isFiltered,
      ) {
    return _repository.getShiftsDomain(data.toJson(), query, isFiltered);
  }

  /// 👩‍⚕️ Get shifts for a specific doctor (used by patient)
  Future<Either<AppError, List<ShiftModel?>>> getShiftssFromPatient(
      Map<String, dynamic> data,
      String? doctorKey,
      ) {
    return _repository.getShiftssFromPatientDomain(data, doctorKey);
  }
}
