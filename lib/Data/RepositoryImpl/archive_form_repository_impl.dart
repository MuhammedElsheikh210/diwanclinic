import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

class ArchiveFormRepositoryImpl extends ArchiveFormRepository {
  final ArchiveFormDataSourceRepo _archiveFormDataSourceRepo;

  ArchiveFormRepositoryImpl(this._archiveFormDataSourceRepo);

  /// ================= GET ALL FORMS =================

  @override
  Future<Either<AppError, List<ArchiveFormModel>>> getFormsDomain(
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await _archiveFormDataSourceRepo.getForms(data);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  /// ================= GET SINGLE FORM =================

  @override
  Future<Either<AppError, ArchiveFormModel>> getFormDomain(
    String formId,
  ) async {
    try {
      final result = await _archiveFormDataSourceRepo.getForm(formId);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  /// ================= CREATE FORM =================

  @override
  Future<Either<AppError, SuccessModel>> createFormDomain(
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await _archiveFormDataSourceRepo.createForm(data);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  /// ================= UPDATE FORM =================

  @override
  Future<Either<AppError, SuccessModel>> updateFormDomain(
    String formId,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await _archiveFormDataSourceRepo.updateForm(formId, data);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  /// ================= DELETE FORM =================

  @override
  Future<Either<AppError, SuccessModel>> deleteFormDomain(String formId) async {
    try {
      final result = await _archiveFormDataSourceRepo.deleteForm(formId);
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }
}
