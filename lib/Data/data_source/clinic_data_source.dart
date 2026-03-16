import '../../index/index_main.dart';

abstract class ClinicDataSourceRepo {
  Future<List<ClinicModel?>> getClinics(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    String? doctorKey,
    bool? isFiltered, {
    bool? fromOnline, // ✅ NEW OPTIONAL PARAM
  });

  Future<List<ClinicModel?>> getClinicsFromPatient(
    Map<String, dynamic> data,
    String? doctorKey,
  );

  Future<SuccessModel> addClinic(
    Map<String, dynamic> data,
    String? doctorKey,
    String key,
  );

  Future<SuccessModel> deleteClinic(
    Map<String, dynamic> data,
    String? doctorKey,
    String key,
  );

  Future<SuccessModel> updateClinic(
    Map<String, dynamic> data,
    String? doctorKey,
    String key,
  );
}
