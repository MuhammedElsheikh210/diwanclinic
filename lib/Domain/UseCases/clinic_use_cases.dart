import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class ClinicUseCases {
  final ClinicRepository _repository;

  ClinicUseCases(this._repository);

  /// 🏥 Add a new clinic
  Future<Either<AppError, SuccessModel>> addClinic(ClinicModel clinic) {
    return _repository.addClinicDomain(
      clinic.toJson(),
      clinic.key ?? "",
      clinic.doctorKey,
    );
  }

  /// 🏥 Update an existing clinic
  Future<Either<AppError, SuccessModel>> updateClinic(ClinicModel clinic) {
    return _repository.updateClinicDomain(
      clinic.toJson(),
      clinic.key ?? "",
      clinic.doctorKey,
    );
  }

  /// 🏥 Delete a clinic by key
  Future<Either<AppError, SuccessModel>> deleteClinic(
      String key,
      String? doctorKey,
      ) {
    return _repository.deleteClinicDomain(
      {},
      key,
      doctorKey,
    );
  }

  /// 🏥 Get all clinics
  Future<Either<AppError, List<ClinicModel?>>> getClinics(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      String? doctorKey,
      bool? isFiltered,
      bool? fromOnline,
      ) {
    return _repository.getClinicsDomain(
      data,
      query,
      doctorKey,
      isFiltered,
      fromOnline,
    );
  }

  /// 👩‍⚕️ Get clinics related to a specific doctor (for patients)
  Future<Either<AppError, List<ClinicModel?>>> getClinicsFromPatient(
      Map<String, dynamic> data,
      String? doctorKey,
      ) {
    return _repository.getClinicsFromPatientDomain(
      data,
      doctorKey,
    );
  }
}