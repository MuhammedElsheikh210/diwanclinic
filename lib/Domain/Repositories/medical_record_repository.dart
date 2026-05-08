import 'package:dartz/dartz.dart';

import '../../index/index_main.dart';

abstract class MedicalRecordPropertyRepository {
  /// 🔍 Fetch properties list
  Future<Either<AppError, List<MedicalRecordPropertyModel?>>>
  getMedicalRecordPropertiesDomain(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  );

  /// 📌 Fetch single property
  Future<Either<AppError, MedicalRecordPropertyModel>>
  getMedicalRecordPropertyDomain(Map<String, dynamic> data);

  /// ➕ Add property
  Future<Either<AppError, SuccessModel>> addMedicalRecordPropertyDomain(
    Map<String, dynamic> data,
    String id,
  );

  /// 🗑 Delete property
  Future<Either<AppError, SuccessModel>> deleteMedicalRecordPropertyDomain(
    Map<String, dynamic> data,
    String id,
  );

  /// 🔄 Update property
  Future<Either<AppError, SuccessModel>> updateMedicalRecordPropertyDomain(
    Map<String, dynamic> data,
    String id,
  );
}
