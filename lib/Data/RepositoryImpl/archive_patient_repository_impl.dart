import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

class ArchivePatientRepositoryImpl extends ArchivePatientRepository {
  final ArchivePatientDataSourceRepo _archivePatientDataSourceRepo;

  ArchivePatientRepositoryImpl(this._archivePatientDataSourceRepo);

  /// ================= GET ALL ARCHIVE PATIENTS =================

  @override
  Future<Either<AppError, List<ArchivePatientModel>>> getArchivePatientsDomain(
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await _archivePatientDataSourceRepo.getArchivePatients(
        data,
      );
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  /// ================= GET SINGLE ARCHIVE PATIENT =================

  @override
  Future<Either<AppError, ArchivePatientModel>> getArchivePatientDomain(
    String archiveId,
  ) async {
    try {
      final result = await _archivePatientDataSourceRepo.getArchivePatient(
        archiveId,
      );
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  /// ================= CREATE ARCHIVE PATIENT =================

  @override
  Future<Either<AppError, SuccessModel>> createArchivePatientDomain(
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await _archivePatientDataSourceRepo.createArchivePatient(
        data,
      );
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  /// ================= UPDATE ARCHIVE PATIENT =================

  @override
  Future<Either<AppError, SuccessModel>> updateArchivePatientDomain(
    String archiveId,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await _archivePatientDataSourceRepo.updateArchivePatient(
        archiveId,
        data,
      );
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  /// ================= DELETE ARCHIVE PATIENT =================

  @override
  Future<Either<AppError, SuccessModel>> deleteArchivePatientDomain(
    String archiveId,
  ) async {
    try {
      final result = await _archivePatientDataSourceRepo.deleteArchivePatient(
        archiveId,
      );
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }
}
