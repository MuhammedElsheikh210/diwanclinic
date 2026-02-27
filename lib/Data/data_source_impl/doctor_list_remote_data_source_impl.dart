import 'package:diwanclinic/Data/Models/doctor_list_model.dart';
import 'package:diwanclinic/Data/data_source/doctor_list_repository.dart';
import '../../index/index_main.dart';

class DoctorListRemoteDataSourceImpl implements DoctorListRemoteDataSource {
  final ClientSourceRepo _clientSourceRepo;

  DoctorListRemoteDataSourceImpl(this._clientSourceRepo);

  @override
  Future<List<DoctorListModel>> getDoctorList(
    Map<String, dynamic> query,
  ) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        "/${ApiConstatns.doctorList}.json",
        params: query,
      );

      final responseList = handleResponse<DoctorListModel>(
        response,
        (json) => DoctorListModel.fromJson(json),
      );

      List<DoctorListModel> doctorList = responseList
          .whereType<DoctorListModel>()
          .toList();

      return doctorList;
    } catch (e) {
      print("❌ [ERROR] - Fetching Doctor List failed: $e");
      return [];
    }
  }

  @override
  Future<DoctorListModel> getDoctor(String id) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        "/${ApiConstatns.doctorList}/$id.json",
      );

      return DoctorListModel.fromJson(response);
    } catch (e) {
      print("❌ [ERROR] - getDoctor failed: $e");
      rethrow;
    }
  }

  @override
  Future<SuccessModel> addDoctor(DoctorListModel doctor) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.PATCH,
        "/${ApiConstatns.doctorList}/${doctor.key}.json",
        params: doctor.toJson(),
      );

      return SuccessModel.fromJson(response);
    } catch (e) {
      print("❌ [ERROR] - addDoctor failed: $e");
      return SuccessModel(message: "Add Doctor failed");
    }
  }

  @override
  Future<SuccessModel> updateDoctor(String id, DoctorListModel doctor) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.PATCH,
        "/${ApiConstatns.doctorList}/$id.json",
        params: doctor.toJson(),
      );

      return SuccessModel.fromJson(response);
    } catch (e) {
      print("❌ [ERROR] - updateDoctor failed: $e");
      return SuccessModel(message: "Update Doctor failed");
    }
  }

  @override
  Future<SuccessModel> deleteDoctor(String id) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.DELETE,
        "/${ApiConstatns.doctorList}/$id.json",
      );

      return response == null
          ? SuccessModel(message: "تمت العملية بنجاح")
          : SuccessModel.fromJson(response);
    } catch (e) {
      print("❌ [ERROR] - deleteDoctor failed: $e");
      return SuccessModel(message: "Delete Doctor failed");
    }
  }
}
