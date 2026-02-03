import '../../index/index_main.dart';

abstract class PatientDataSourceRepo {
  Future<List<PatientModel?>> getPatients(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      );

  Future<SuccessModel> addPatient(Map<String, dynamic> data, String key);

  Future<SuccessModel> deletePatient(Map<String, dynamic> data, String key);

  Future<SuccessModel> updatePatient(Map<String, dynamic> data, String key);
}
