import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class ArchiveFormUseCases {
  final ArchiveFormRepository _repository;

  ArchiveFormUseCases(this._repository);

  /// 📄 Create new archive form
  Future<Either<AppError, SuccessModel>> createForm(ArchiveFormModel form) {
    return _repository.createFormDomain(form.toJson());
  }

  /// ✏️ Update existing archive form
  Future<Either<AppError, SuccessModel>> updateForm(
    String formId,
    ArchiveFormModel form,
  ) {
    return _repository.updateFormDomain(formId, form.toJson());
  }

  /// 🗑 Delete archive form
  Future<Either<AppError, SuccessModel>> deleteForm(String formId) {
    return _repository.deleteFormDomain(formId);
  }

  /// 📋 Get all archive forms
  Future<Either<AppError, List<ArchiveFormModel>>> getForms(
    Map<String, dynamic> data,
  ) {
    return _repository.getFormsDomain(data);
  }

  /// 📌 Get single archive form
  Future<Either<AppError, ArchiveFormModel>> getForm(String formId) {
    return _repository.getFormDomain(formId);
  }
}
