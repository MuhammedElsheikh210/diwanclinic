import '../../index/index_main.dart';

class MedicalRecordPropertyDataSourceRepoImpl
    extends MedicalRecordPropertyDataSourceRepo {
  final ClientSourceRepo _clientSourceRepo;

  MedicalRecordPropertyDataSourceRepoImpl(this._clientSourceRepo);

  @override
  Future<List<MedicalRecordPropertyModel?>> getMedicalRecordProperties(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  ) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.GET,

        "/${ApiConstatns.medicalRecordProperties}.json",

        params: data,
      );

      List<MedicalRecordPropertyModel?> properties =
          handleResponse<MedicalRecordPropertyModel>(
            response,

            (json) => MedicalRecordPropertyModel.fromJson(json),
          );

      return properties;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<MedicalRecordPropertyModel> getMedicalRecordProperty(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.GET,

        "/${ApiConstatns.medicalRecordProperties}.json",

        params: data,
      );

      final propertyJson = response.values.first as Map<String, dynamic>;

      final property = MedicalRecordPropertyModel.fromJson(propertyJson);

      return property;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SuccessModel> addMedicalRecordProperty(
    Map<String, dynamic> data,
    String id,
  ) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.PATCH,

        "/${ApiConstatns.medicalRecordProperties}/$id.json",

        params: data,
      );

      return SuccessModel.fromJson(response);
    } catch (e) {
      return SuccessModel(message: "Add Medical Record Property failed");
    }
  }

  @override
  Future<SuccessModel> deleteMedicalRecordProperty(
    Map<String, dynamic> data,
    String id,
  ) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.DELETE,

        "/${ApiConstatns.medicalRecordProperties}/$id.json",

        params: data,
      );

      return response == null
          ? SuccessModel(message: "تمت العملية بنجاح")
          : SuccessModel.fromJson(response);
    } catch (e) {
      return SuccessModel(message: "Delete Property failed");
    }
  }

  @override
  Future<SuccessModel> updateMedicalRecordProperty(
    Map<String, dynamic> data,
    String id,
  ) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.PATCH,

        "/${ApiConstatns.medicalRecordProperties}/$id.json",

        params: data,
      );

      return SuccessModel.fromJson(response);
    } catch (e) {
      return SuccessModel(message: "Update Property failed");
    }
  }
}
