import '../../index/index_main.dart';

abstract class DoctorReviewDataSourceRepo {
  Future<List<DoctorReviewModel?>> getDoctorReviews(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  );

  Future<List<DoctorReviewModel?>> getDoctorReviewsFromPatient(
    Map<String, dynamic> data,
    String? doctorKey,
  );

  Future<SuccessModel> addDoctorReview(Map<String, dynamic> data, String key);

  Future<SuccessModel> addDoctorFromPatientReview(
    Map<String, dynamic> data,
    String key,
    String doctor_key,
  );

  //
  Future<SuccessModel> deleteDoctorReview(
    Map<String, dynamic> data,
    String key,
  );

  Future<SuccessModel> updateDoctorReview(
    Map<String, dynamic> data,
    String key,
  );
}
