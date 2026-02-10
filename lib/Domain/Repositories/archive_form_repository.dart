import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

abstract class ArchiveFormRepository {
  /// 🔍 Fetch all forms
  Future<Either<AppError, List<ArchiveFormModel>>> getFormsDomain(
      Map<String, dynamic> data,
      );

  /// 📌 Fetch single form
  Future<Either<AppError, ArchiveFormModel>> getFormDomain(
      String formId,
      );

  /// ➕ Create new form
  Future<Either<AppError, SuccessModel>> createFormDomain(
      Map<String, dynamic> data,
      );

  /// 🔄 Update form
  Future<Either<AppError, SuccessModel>> updateFormDomain(
      String formId,
      Map<String, dynamic> data,
      );

  /// 🗑 Delete form
  Future<Either<AppError, SuccessModel>> deleteFormDomain(
      String formId,
      );
}
