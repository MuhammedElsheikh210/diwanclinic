import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

abstract class PatientRepository {
  Future<Either<AppError, List<PatientModel?>>> getPatientsDomain(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      );

  Future<Either<AppError, SuccessModel>> addPatientDomain(
      Map<String, dynamic> data,
      String key,
      );

  Future<Either<AppError, SuccessModel>> deletePatientDomain(
      Map<String, dynamic> data,
      String key,
      );

  Future<Either<AppError, SuccessModel>> updatePatientDomain(
      Map<String, dynamic> data,
      String key,
      );
}
