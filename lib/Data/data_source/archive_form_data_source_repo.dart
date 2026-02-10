import '../../index/index_main.dart';

abstract class ArchiveFormDataSourceRepo {
  /// 🔍 Get all forms (if you plan multiple forms later)
  Future<List<ArchiveFormModel>> getForms(Map<String, dynamic> data);

  /// 📌 Get single form by id
  Future<ArchiveFormModel> getForm(String formId);

  /// ➕ Create new form (with fields)
  Future<SuccessModel> createForm(Map<String, dynamic> data);

  /// 🔄 Update existing form
  Future<SuccessModel> updateForm(String formId, Map<String, dynamic> data);

  /// 🗑 Delete form
  Future<SuccessModel> deleteForm(String formId);
}
