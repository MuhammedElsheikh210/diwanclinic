import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

class ClinicRepositoryImpl extends ClinicRepository {
  final ClinicDataSourceRepo _clinicDataSourceRepo;

  ClinicRepositoryImpl(this._clinicDataSourceRepo);

  @override
  Future<Either<AppError, List<ClinicModel?>>> getClinicsDomain(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
    bool? fromOnline, //
  ) async {
    try {
      final result = await _clinicDataSourceRepo.getClinics(
        data,
        query,
        isFiltered,
        fromOnline: fromOnline,
      );
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  /// 🩺 Get clinics for a specific doctor (used by patients)
  @override
  Future<Either<AppError, List<ClinicModel?>>> getClinicsFromPatientDomain(
    Map<String, dynamic> data,
    String? doctorKey,
  ) async {
    try {
      final result = await _clinicDataSourceRepo.getClinicsFromPatient(
        data,
        doctorKey,
      );
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> addClinicDomain(
    Map<String, dynamic> data,
    String key,
  ) async {
    try {
      final result = await _clinicDataSourceRepo.addClinic(data, key);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> deleteClinicDomain(
    Map<String, dynamic> data,
    String key,
  ) async {
    try {
      final result = await _clinicDataSourceRepo.deleteClinic(data, key);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> updateClinicDomain(
    Map<String, dynamic> data,
    String key,
  ) async {
    try {
      final result = await _clinicDataSourceRepo.updateClinic(data, key);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }
}
