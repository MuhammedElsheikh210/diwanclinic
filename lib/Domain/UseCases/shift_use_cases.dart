import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class ShiftUseCases {
  final ShiftRepository _repository;

  ShiftUseCases(this._repository);

  // =========================================================
  // 🔹 ADD SHIFT
  // =========================================================
  Future<Either<AppError, SuccessModel>> addShift(ShiftModel shift) {
    return _repository.addShiftDomain(
      shift.toJson(),
      shift.key ?? "",
    );
  }

  // =========================================================
  // 🔹 UPDATE SHIFT
  // =========================================================
  Future<Either<AppError, SuccessModel>> updateShift(ShiftModel shift) {
    return _repository.updateShiftDomain(
      shift.toJson(),
      shift.key ?? "",
    );
  }

  // =========================================================
  // 🔹 DELETE SHIFT
  // =========================================================
  Future<Either<AppError, SuccessModel>> deleteShift(String key) {
    return _repository.deleteShiftDomain({}, key);
  }

  // =========================================================
  // 🔹 GET SHIFTS (Local First / Force Online)
  // =========================================================
  Future<Either<AppError, List<ShiftModel?>>> getShifts(
      FirebaseFilter data,
      SQLiteQueryParams query,
      bool? isFiltered, {
        bool? fromOnline,
      }) {
    return _repository.getShiftsDomain(
      data.toJson(),
      query,
      isFiltered,
      fromOnline: fromOnline,
    );
  }

  // =========================================================
  // 🔹 GET SHIFTS FROM PATIENT
  // =========================================================
  Future<Either<AppError, List<ShiftModel?>>> getShiftssFromPatient(
      Map<String, dynamic> data,
      String? doctorKey,
      ) {
    return _repository.getShiftssFromPatientDomain(
      data,
      doctorKey,
    );
  }
}