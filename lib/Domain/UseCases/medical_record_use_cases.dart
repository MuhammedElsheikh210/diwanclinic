import 'package:dartz/dartz.dart';

import '../../../index/index_main.dart';

class MedicalRecordPropertyUseCases {
  final MedicalRecordPropertyRepository _repository;

  MedicalRecordPropertyUseCases(this._repository);

  /// ➕ Add property
  Future<Either<AppError, SuccessModel>> addMedicalRecordProperty(
    MedicalRecordPropertyModel property,
  ) {
    return _repository.addMedicalRecordPropertyDomain(
      property.toJson(),
      property.key ?? "",
    );
  }

  /// 🔄 Update property
  Future<Either<AppError, SuccessModel>> updateMedicalRecordProperty(
    MedicalRecordPropertyModel property,
  ) {
    return _repository.updateMedicalRecordPropertyDomain(
      property.toJson(),
      property.key ?? "",
    );
  }

  /// 🗑 Delete property
  Future<Either<AppError, SuccessModel>> deleteMedicalRecordProperty(
    String key,
  ) {
    return _repository.deleteMedicalRecordPropertyDomain({}, key);
  }

  /// 🔍 Get all properties
  Future<Either<AppError, List<MedicalRecordPropertyModel?>>>
  getMedicalRecordProperties(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  ) {
    return _repository.getMedicalRecordPropertiesDomain(
      data,
      query,
      isFiltered,
    );
  }

  /// 📌 Get single property
  Future<Either<AppError, MedicalRecordPropertyModel>> getMedicalRecordProperty(
    Map<String, dynamic> data,
  ) {
    return _repository.getMedicalRecordPropertyDomain(data);
  }
}
