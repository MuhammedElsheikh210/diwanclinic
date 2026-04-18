
import '../../index/index_main.dart';

class MedicalCenterDataSourceRepoImpl implements MedicalCenterDataSourceRepo {
  final ClientSourceRepo _clientSourceRepo;

  MedicalCenterDataSourceRepoImpl(this._clientSourceRepo);

  @override
  Future<List<MedicalCenterModel?>> getMedicalCenters(
      Map<String, dynamic> data,
      ) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        "/${ApiConstatns.medicalCenters}.json",
        params: data,
      );

      List<MedicalCenterModel?> centerList =
      handleResponse<MedicalCenterModel>(
        response,
            (json) => MedicalCenterModel.fromJson(json),
      );

      return centerList;
    } catch (e) {
      
      return [];
    }
  }

  @override
  Future<MedicalCenterModel> getMedicalCenter(
      Map<String, dynamic> data,
      ) async {
    final response = await _clientSourceRepo.request(
      HttpMethod.GET,
      "/${ApiConstatns.medicalCenters}.json",
      params: data,
    );

    final centerJson = response.values.first as Map<String, dynamic>;
    return MedicalCenterModel.fromJson(centerJson);
  }

  @override
  Future<SuccessModel> addMedicalCenter(
      Map<String, dynamic> data,
      String id,
      ) async {
    final response = await _clientSourceRepo.request(
      HttpMethod.PATCH,
      "/${ApiConstatns.medicalCenters}/$id.json",
      params: data,
    );

    return SuccessModel.fromJson(response);
  }

  @override
  Future<SuccessModel> deleteMedicalCenter(
      Map<String, dynamic> data,
      String id,
      ) async {
    final response = await _clientSourceRepo.request(
      HttpMethod.DELETE,
      "/${ApiConstatns.medicalCenters}/$id.json",
      params: data,
    );

    return response == null
        ? SuccessModel(message: "تمت العملية بنجاح")
        : SuccessModel.fromJson(response);
  }

  @override
  Future<SuccessModel> updateMedicalCenter(
      Map<String, dynamic> data,
      String id,
      ) async {
    final response = await _clientSourceRepo.request(
      HttpMethod.PATCH,
      "/${ApiConstatns.medicalCenters}/$id.json",
      params: data,
    );

    return SuccessModel.fromJson(response);
  }


}