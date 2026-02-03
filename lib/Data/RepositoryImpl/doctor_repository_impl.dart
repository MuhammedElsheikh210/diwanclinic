import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

class DoctorRepositoryImpl extends DoctorRepository {
  final DoctorDataSourceRepo _doctorDataSourceRepo;

  DoctorRepositoryImpl(this._doctorDataSourceRepo);

  @override
  Future<Either<AppError, List<DoctorModel?>>> getDoctorsDomain(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      ) async {
    try {
      final result = await _doctorDataSourceRepo.getDoctors(data, query, isFiltered);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> addDoctorDomain(
      Map<String, dynamic> data,
      String key,
      ) async {
    try {
      final result = await _doctorDataSourceRepo.addDoctor(data, key);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> deleteDoctorDomain(
      Map<String, dynamic> data,
      String key,
      ) async {
    try {
      final result = await _doctorDataSourceRepo.deleteDoctor(data, key);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> updateDoctorDomain(
      Map<String, dynamic> data,
      String key,
      ) async {
    try {
      final result = await _doctorDataSourceRepo.updateDoctor(data, key);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }
}
