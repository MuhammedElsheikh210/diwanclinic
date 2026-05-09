import 'package:dartz/dartz.dart';

import '../../../index/index_main.dart';

class MedicalRecordUseCases {
  final MedicalRecordRepository _repository;

  MedicalRecordUseCases(this._repository);

  /// ➕ Add medical record
  Future<Either<AppError, SuccessModel>> addMedicalRecord(
    MedicalRecordModel medicalRecord,
  ) {
    return _repository.addMedicalRecordDomain(
      medicalRecord.toJson(),
      medicalRecord.key ?? "",
    );
  }

  /// 🔄 Update medical record
  Future<Either<AppError, SuccessModel>> updateMedicalRecord(
    MedicalRecordModel medicalRecord,
  ) {
    return _repository.updateMedicalRecordDomain(
      medicalRecord.toJson(),
      medicalRecord.key ?? "",
    );
  }

  /// 🗑 Delete medical record
  Future<Either<AppError, SuccessModel>> deleteMedicalRecord(String key) {
    return _repository.deleteMedicalRecordDomain({}, key);
  }

  /// 🔍 Get all medical records
  Future<Either<AppError, List<MedicalRecordModel?>>> getMedicalRecords(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  ) {
    return _repository.getMedicalRecordsDomain(data, query, isFiltered);
  }

  /// 📌 Get single medical record
  Future<Either<AppError, MedicalRecordModel>> getMedicalRecord(
    Map<String, dynamic> data,
  ) {
    return _repository.getMedicalRecordDomain(data);
  }
}
