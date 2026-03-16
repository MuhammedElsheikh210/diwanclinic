import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

class MedicalCenterRepositoryImpl extends MedicalCenterRepository {
  final MedicalCenterDataSourceRepo _medicalCenterDataSourceRepo;

  MedicalCenterRepositoryImpl(this._medicalCenterDataSourceRepo);

  @override
  Future<Either<AppError, List<MedicalCenterModel?>>> getMedicalCentersDomain(
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await _medicalCenterDataSourceRepo.getMedicalCenters(data);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, MedicalCenterModel>> getMedicalCenterDomain(
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await _medicalCenterDataSourceRepo.getMedicalCenter(data);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> addMedicalCenterDomain(
    Map<String, dynamic> data,
    String id,
  ) async {
    try {
      final result = await _medicalCenterDataSourceRepo.addMedicalCenter(
        data,
        id,
      );
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> deleteMedicalCenterDomain(
    Map<String, dynamic> data,
    String id,
  ) async {
    try {
      final result = await _medicalCenterDataSourceRepo.deleteMedicalCenter(
        data,
        id,
      );
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> updateMedicalCenterDomain(
    Map<String, dynamic> data,
    String id,
  ) async {
    try {
      final result = await _medicalCenterDataSourceRepo.updateMedicalCenter(
        data,
        id,
      );
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }
}
