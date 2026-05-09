import 'package:dartz/dartz.dart';

import '../../index/index_main.dart';

class MedicalRecordRepositoryImpl extends MedicalRecordRepository {
  final MedicalRecordDataSourceRepo _medicalRecordDataSourceRepo;

  MedicalRecordRepositoryImpl(this._medicalRecordDataSourceRepo);

  @override
  Future<Either<AppError, List<MedicalRecordModel?>>> getMedicalRecordsDomain(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  ) async {
    try {
      final result = await _medicalRecordDataSourceRepo.getMedicalRecords(
        data,
        query,
        isFiltered,
      );

      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, MedicalRecordModel>> getMedicalRecordDomain(
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await _medicalRecordDataSourceRepo.getMedicalRecord(data);

      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> addMedicalRecordDomain(
    Map<String, dynamic> data,
    String id,
  ) async {
    try {
      final result = await _medicalRecordDataSourceRepo.addMedicalRecord(
        data,
        id,
      );

      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> deleteMedicalRecordDomain(
    Map<String, dynamic> data,
    String id,
  ) async {
    try {
      final result = await _medicalRecordDataSourceRepo.deleteMedicalRecord(
        data,
        id,
      );

      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> updateMedicalRecordDomain(
    Map<String, dynamic> data,
    String id,
  ) async {
    try {
      final result = await _medicalRecordDataSourceRepo.updateMedicalRecord(
        data,
        id,
      );

      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }
}
