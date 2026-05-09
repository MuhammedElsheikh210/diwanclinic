import 'package:dartz/dartz.dart';

import '../../index/index_main.dart';

abstract class MedicalRecordRepository {
  /// 🔍 Fetch medical records
  Future<Either<AppError, List<MedicalRecordModel?>>>
  getMedicalRecordsDomain(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      );

  /// 📌 Fetch single medical record
  Future<Either<AppError, MedicalRecordModel>>
  getMedicalRecordDomain(
      Map<String, dynamic> data,
      );

  /// ➕ Add medical record
  Future<Either<AppError, SuccessModel>>
  addMedicalRecordDomain(
      Map<String, dynamic> data,
      String id,
      );

  /// 🗑 Delete medical record
  Future<Either<AppError, SuccessModel>>
  deleteMedicalRecordDomain(
      Map<String, dynamic> data,
      String id,
      );

  /// 🔄 Update medical record
  Future<Either<AppError, SuccessModel>>
  updateMedicalRecordDomain(
      Map<String, dynamic> data,
      String id,
      );
}