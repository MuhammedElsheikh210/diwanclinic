import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

abstract class ArchivePatientRepository {
  /// 🔍 Fetch all archive records
  Future<Either<AppError, List<ArchivePatientModel>>>
  getArchivePatientsDomain(
      Map<String, dynamic> data,
      );

  /// 📌 Fetch single archive record
  Future<Either<AppError, ArchivePatientModel>>
  getArchivePatientDomain(
      String archiveId,
      );

  /// ➕ Create archive record
  Future<Either<AppError, SuccessModel>>
  createArchivePatientDomain(
      Map<String, dynamic> data,
      );

  /// 🔄 Update archive record
  Future<Either<AppError, SuccessModel>>
  updateArchivePatientDomain(
      String archiveId,
      Map<String, dynamic> data,
      );

  /// 🗑 Delete archive record
  Future<Either<AppError, SuccessModel>>
  deleteArchivePatientDomain(
      String archiveId,
      );
}
