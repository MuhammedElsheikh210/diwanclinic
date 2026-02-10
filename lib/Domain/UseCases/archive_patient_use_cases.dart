import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class ArchivePatientUseCases {
  final ArchivePatientRepository _repository;

  ArchivePatientUseCases(this._repository);

  /// 📄 Create new archive patient
  Future<Either<AppError, SuccessModel>> createArchivePatient(
      ArchivePatientModel archivePatient,
      ) {
    return _repository.createArchivePatientDomain(
      archivePatient.toJson(),
    );
  }

  /// ✌️ Update existing archive patient
  Future<Either<AppError, SuccessModel>> updateArchivePatient(
      String archiveId,
      ArchivePatientModel archivePatient,
      ) {
    return _repository.updateArchivePatientDomain(
      archiveId,
      archivePatient.toJson(),
    );
  }

  /// 🗑 Delete archive patient
  Future<Either<AppError, SuccessModel>> deleteArchivePatient(
      String archiveId,
      ) {
    return _repository.deleteArchivePatientDomain(archiveId);
  }

  /// 📋 Get all archive patients
  Future<Either<AppError, List<ArchivePatientModel>>> getArchivePatients(
      Map<String, dynamic> data,
      ) {
    return _repository.getArchivePatientsDomain(data);
  }

  /// 📌 Get single archive patient
  Future<Either<AppError, ArchivePatientModel>> getArchivePatient(
      String archiveId,
      ) {
    return _repository.getArchivePatientDomain(archiveId);
  }
}
