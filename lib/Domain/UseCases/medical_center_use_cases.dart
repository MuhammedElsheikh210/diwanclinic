// 📄 medical_center_use_cases.dart

import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class MedicalCenterUseCases {
  final MedicalCenterRepository _repository;

  MedicalCenterUseCases(this._repository);

  /// ➕ Add a new medical center
  Future<Either<AppError, SuccessModel>> addMedicalCenter(
    MedicalCenterModel center,
  ) {
    return _repository.addMedicalCenterDomain(
      center.toJson(),
      center.key ?? "",
    );
  }

  /// 🔄 Update medical center
  Future<Either<AppError, SuccessModel>> updateMedicalCenter(
    MedicalCenterModel center,
  ) {
    return _repository.updateMedicalCenterDomain(
      center.toJson(),
      center.key ?? "",
    );
  }

  /// 🗑 Delete medical center
  Future<Either<AppError, SuccessModel>> deleteMedicalCenter(String key) {
    return _repository.deleteMedicalCenterDomain({}, key);
  }

  /// 🔍 Get medical centers list
  Future<Either<AppError, List<MedicalCenterModel?>>> getMedicalCenters(
    Map<String, dynamic> query,
  ) {
    return _repository.getMedicalCentersDomain(query);
  }

  /// 📌 Get single medical center
  Future<Either<AppError, MedicalCenterModel>> getMedicalCenter(
    Map<String, dynamic> query,
  ) {
    return _repository.getMedicalCenterDomain(query);
  }
}
