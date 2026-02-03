import 'package:dartz/dartz.dart';

import '../../index/index_main.dart';

class PatientRepositoryImpl extends PatientRepository {
  final PatientDataSourceRepo _patientDataSourceRepo;

  PatientRepositoryImpl(this._patientDataSourceRepo);

  @override
  Future<Either<AppError, List<PatientModel?>>> getPatientsDomain(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      ) async {
    try {
      final result = await _patientDataSourceRepo.getPatients(data, query, isFiltered);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> addPatientDomain(
      Map<String, dynamic> data,
      String key,
      ) async {
    try {
      final result = await _patientDataSourceRepo.addPatient(data, key);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> deletePatientDomain(
      Map<String, dynamic> data,
      String key,
      ) async {
    try {
      final result = await _patientDataSourceRepo.deletePatient(data, key);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> updatePatientDomain(
      Map<String, dynamic> data,
      String key,
      ) async {
    try {
      final result = await _patientDataSourceRepo.updatePatient(data, key);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }
}
