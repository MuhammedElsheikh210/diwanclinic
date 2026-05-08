import 'package:dartz/dartz.dart';

import '../../index/index_main.dart';

class MedicalRecordPropertyRepositoryImpl
    extends MedicalRecordPropertyRepository {
  final MedicalRecordPropertyDataSourceRepo
  _medicalRecordPropertyDataSourceRepo;

  MedicalRecordPropertyRepositoryImpl(
    this._medicalRecordPropertyDataSourceRepo,
  );

  @override
  Future<Either<AppError, List<MedicalRecordPropertyModel?>>>
  getMedicalRecordPropertiesDomain(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  ) async {
    try {
      final result = await _medicalRecordPropertyDataSourceRepo
          .getMedicalRecordProperties(data, query, isFiltered);

      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, MedicalRecordPropertyModel>>
  getMedicalRecordPropertyDomain(Map<String, dynamic> data) async {
    try {
      final result = await _medicalRecordPropertyDataSourceRepo
          .getMedicalRecordProperty(data);

      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> addMedicalRecordPropertyDomain(
    Map<String, dynamic> data,
    String id,
  ) async {
    try {
      final result = await _medicalRecordPropertyDataSourceRepo
          .addMedicalRecordProperty(data, id);

      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> deleteMedicalRecordPropertyDomain(
    Map<String, dynamic> data,
    String id,
  ) async {
    try {
      final result = await _medicalRecordPropertyDataSourceRepo
          .deleteMedicalRecordProperty(data, id);

      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> updateMedicalRecordPropertyDomain(
    Map<String, dynamic> data,
    String id,
  ) async {
    try {
      final result = await _medicalRecordPropertyDataSourceRepo
          .updateMedicalRecordProperty(data, id);

      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }
}
