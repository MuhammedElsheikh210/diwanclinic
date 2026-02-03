import '../../index/index_main.dart';

abstract class DoctorDataSourceRepo {
  Future<List<DoctorModel?>> getDoctors(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  );

  Future<SuccessModel> addDoctor(Map<String, dynamic> data, String key);

  Future<SuccessModel> deleteDoctor(Map<String, dynamic> data, String key);

  Future<SuccessModel> updateDoctor(Map<String, dynamic> data, String key);
}
