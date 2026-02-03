import 'package:diwanclinic/Data/data_source/doctor_feedback_data_source.dart';
import '../../index/index_main.dart';

class DoctorReviewDataSourceRepoImpl extends DoctorReviewDataSourceRepo {
  final ClientSourceRepo _clientSourceRepo;

  DoctorReviewDataSourceRepoImpl(this._clientSourceRepo);

  @override
  Future<List<DoctorReviewModel?>> getDoctorReviews(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  ) async {
    try {
      // 🔸 Local fetch (disabled)
      // final sqliteData = await _sqliteRepo.getAll(query: query);
      // if (sqliteData.isNotEmpty || (sqliteData.isEmpty && isFiltered == true)) {
      //   return sqliteData;
      // }
    } catch (_) {}

    try {
      // 🔹 Online fetch
      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        "/${ApiConstatns.doctor_reviews}.json",
        params: data,
      );

      return handleResponse<DoctorReviewModel>(
        response,
        (json) => DoctorReviewModel.fromJson(json),
      );
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<DoctorReviewModel?>> getDoctorReviewsFromPatient(
    Map<String, dynamic> data,
    String? doctorKey,
  ) async {
    try {
      // 🔸 Local fetch (disabled)
      // final sqliteData = await _sqliteRepo.getAll(query: query);
      // if (sqliteData.isNotEmpty || (sqliteData.isEmpty && isFiltered == true)) {
      //   return sqliteData;
      // }
    } catch (_) {}

    try {
      // 🔹 Online fetch
      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        "/${ApiConstatns.doctor_reviews_patient}$doctorKey/doctor_reviews.json",
        params: data,
      );

      return handleResponse<DoctorReviewModel>(
        response,
        (json) => DoctorReviewModel.fromJson(json),
      );
    } catch (_) {
      return [];
    }
  }

  @override
  Future<SuccessModel> addDoctorReview(
    Map<String, dynamic> data,
    String key,
  ) async {
    try {
      // 🔹 Online add
      final response = await _clientSourceRepo.request(
        HttpMethod.PATCH,
        "/${ApiConstatns.doctor_reviews}/$key.json",
        params: data,
      );
      return SuccessModel.fromJson(response);
    } catch (_) {
      return SuccessModel(message: "حدث خطأ أثناء الإضافة");
    }
  }

  @override
  Future<SuccessModel> addDoctorFromPatientReview(
    Map<String, dynamic> data,
    String key,
    String doctor_key,
  ) async {
    try {
      // 🔹 Online add
      final response = await _clientSourceRepo.request(
        HttpMethod.PATCH,
        "/${ApiConstatns.doctor_reviews_patient}$doctor_key/doctor_reviews/$key.json",
        params: data,
      );
      return SuccessModel.fromJson(response);
    } catch (_) {
      return SuccessModel(message: "حدث خطأ أثناء الإضافة");
    }
  }

  @override
  Future<SuccessModel> deleteDoctorReview(
    Map<String, dynamic> data,
    String key,
  ) async {
    try {
      // 🔹 Online delete
      final response = await _clientSourceRepo.request(
        HttpMethod.DELETE,
        "/${ApiConstatns.doctor_reviews}/$key.json",
        params: data,
      );
      return SuccessModel.fromJson(
        response ?? {"message": "تم حذف التقييم بنجاح"},
      );
    } catch (_) {
      return SuccessModel(message: "حدث خطأ أثناء الحذف");
    }
  }

  @override
  Future<SuccessModel> updateDoctorReview(
    Map<String, dynamic> data,
    String key,
  ) async {
    try {
      // 🔹 Online update
      final response = await _clientSourceRepo.request(
        HttpMethod.PATCH,
        "/${ApiConstatns.doctor_reviews}/$key.json",
        params: data,
      );
      return SuccessModel.fromJson(response);
    } catch (_) {
      return SuccessModel(message: "حدث خطأ أثناء التحديث");
    }
  }
}
