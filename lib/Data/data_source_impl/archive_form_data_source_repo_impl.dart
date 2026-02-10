import '../../index/index_main.dart';

class ArchiveFormDataSourceRepoImpl extends ArchiveFormDataSourceRepo {
  final ClientSourceRepo _clientSourceRepo;

  ArchiveFormDataSourceRepoImpl(this._clientSourceRepo);

  /// ================= GET ALL FORMS =================

  @override
  Future<List<ArchiveFormModel>> getForms(
      Map<String, dynamic> data,
      ) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        "/${ApiConstatns.archiveForms}.json",
        params: data,
      );

      if (response == null) return [];

      final Map<String, dynamic> jsonMap =
      Map<String, dynamic>.from(response);

      final List<ArchiveFormModel> forms = [];

      jsonMap.forEach((id, value) {
        final formJson = Map<String, dynamic>.from(value);

        forms.add(
          ArchiveFormModel.fromJson(
            id,
            formJson,
          ),
        );
      });

      return forms;
    } catch (e) {
      print("❌ [ArchiveForm] Get forms failed: $e");
      return [];
    }
  }

  /// ================= GET SINGLE FORM =================

  @override
  Future<ArchiveFormModel> getForm(String formId) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        "/${ApiConstatns.archiveForms}/$formId.json",
      );

      return ArchiveFormModel.fromJson(
        formId,
        Map<String, dynamic>.from(response),
      );
    } catch (e) {
      print("❌ [ArchiveForm] Get form failed: $e");
      rethrow;
    }
  }

  /// ================= CREATE FORM =================

  @override
  Future<SuccessModel> createForm(
      Map<String, dynamic> data,
      ) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.POST,
        "/${ApiConstatns.archiveForms}.json",
        params: data,
      );

      return SuccessModel.fromJson(response);
    } catch (e) {
      print("❌ [ArchiveForm] Create form failed: $e");
      return SuccessModel(message: "Create form failed");
    }
  }

  /// ================= UPDATE FORM =================

  @override
  Future<SuccessModel> updateForm(
      String formId,
      Map<String, dynamic> data,
      ) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.PATCH,
        "/${ApiConstatns.archiveForms}/$formId.json",
        params: data,
      );

      return SuccessModel.fromJson(response);
    } catch (e) {
      print("❌ [ArchiveForm] Update form failed: $e");
      return SuccessModel(message: "Update form failed");
    }
  }

  /// ================= DELETE FORM =================

  @override
  Future<SuccessModel> deleteForm(String formId) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.DELETE,
        "/${ApiConstatns.archiveForms}/$formId.json",
      );

      return response == null
          ? SuccessModel(message: "Form deleted successfully")
          : SuccessModel.fromJson(response);
    } catch (e) {
      print("❌ [ArchiveForm] Delete form failed: $e");
      return SuccessModel(message: "Delete form failed");
    }
  }
}
