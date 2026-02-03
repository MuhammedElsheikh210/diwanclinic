import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

abstract class DoctorRepository {
  Future<Either<AppError, List<DoctorModel?>>> getDoctorsDomain(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      );

  Future<Either<AppError, SuccessModel>> addDoctorDomain(
      Map<String, dynamic> data,
      String key,
      );

  Future<Either<AppError, SuccessModel>> deleteDoctorDomain(
      Map<String, dynamic> data,
      String key,
      );

  Future<Either<AppError, SuccessModel>> updateDoctorDomain(
      Map<String, dynamic> data,
      String key,
      );
}
