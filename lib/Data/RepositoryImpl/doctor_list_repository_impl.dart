import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

class DoctorListRepositoryImpl extends DoctorListRepository {
  final DoctorListRemoteDataSource _doctorListRemoteDataSource;

  DoctorListRepositoryImpl(this._doctorListRemoteDataSource);

  @override
  Future<Either<AppError, List<DoctorListModel>>> getDoctorListDomain(
      Map<String, dynamic> query,
      ) async {
    try {
      final result =
      await _doctorListRemoteDataSource.getDoctorList(query);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, DoctorListModel>> getDoctorDomain(
      String id,
      ) async {
    try {
      final result =
      await _doctorListRemoteDataSource.getDoctor(id);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> addDoctorDomain(
      DoctorListModel doctor,
      ) async {
    try {
      final result =
      await _doctorListRemoteDataSource.addDoctor(doctor);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> updateDoctorDomain(
      String id,
      DoctorListModel doctor,
      ) async {
    try {
      final result =
      await _doctorListRemoteDataSource.updateDoctor(id, doctor);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> deleteDoctorDomain(
      String id,
      ) async {
    try {
      final result =
      await _doctorListRemoteDataSource.deleteDoctor(id);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }
}