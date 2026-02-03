import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

abstract class ClinicRepository {
  Future<Either<AppError, List<ClinicModel?>>> getClinicsDomain(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      bool? fromOnline,   //
      );

  /// 🩺 Get clinics for a specific doctor (for patients)
  Future<Either<AppError, List<ClinicModel?>>> getClinicsFromPatientDomain(
      Map<String, dynamic> data,
      String? doctorKey,
      );

  Future<Either<AppError, SuccessModel>> addClinicDomain(
      Map<String, dynamic> data,
      String key,
      );

  Future<Either<AppError, SuccessModel>> deleteClinicDomain(
      Map<String, dynamic> data,
      String key,
      );

  Future<Either<AppError, SuccessModel>> updateClinicDomain(
      Map<String, dynamic> data,
      String key,
      );
}
