import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class DoctorUseCases {
  final DoctorRepository _repository;

  DoctorUseCases(this._repository);

  Future<Either<AppError, SuccessModel>> addDoctor(DoctorModel doctor) {
    return _repository.addDoctorDomain(doctor.toJson(), doctor.key ?? "");
  }

  Future<Either<AppError, SuccessModel>> updateDoctor(DoctorModel doctor) {
    return _repository.updateDoctorDomain(doctor.toJson(), doctor.key ?? "");
  }

  Future<Either<AppError, SuccessModel>> deleteDoctor(String key) {
    return _repository.deleteDoctorDomain({}, key);
  }

  Future<Either<AppError, List<DoctorModel?>>> getDoctors(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      ) {
    return _repository.getDoctorsDomain(data, query, isFiltered);
  }
}
