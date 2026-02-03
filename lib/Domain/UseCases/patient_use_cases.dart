import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class PatientUseCases {
  final PatientRepository _repository;

  PatientUseCases(this._repository);

  Future<Either<AppError, SuccessModel>> addPatient(PatientModel patient) {
    return _repository.addPatientDomain(patient.toJson(), patient.key ?? "");
  }

  Future<Either<AppError, SuccessModel>> updatePatient(PatientModel patient) {
    return _repository.updatePatientDomain(patient.toJson(), patient.key ?? "");
  }

  Future<Either<AppError, SuccessModel>> deletePatient(String key) {
    return _repository.deletePatientDomain({}, key);
  }

  Future<Either<AppError, List<PatientModel?>>> getPatients(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      ) {
    return _repository.getPatientsDomain(data, query, isFiltered);
  }
}
