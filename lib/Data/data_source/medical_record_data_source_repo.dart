import '../../index/index_main.dart';

abstract class MedicalRecordPropertyDataSourceRepo {
  /// 🔹 Get properties
  Future<List<MedicalRecordPropertyModel?>> getMedicalRecordProperties(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  );

  /// 🔹 Get single property
  Future<MedicalRecordPropertyModel> getMedicalRecordProperty(
    Map<String, dynamic> data,
  );

  /// 🔹 Add property
  Future<SuccessModel> addMedicalRecordProperty(
    Map<String, dynamic> data,
    String id,
  );

  /// 🔹 Delete property
  Future<SuccessModel> deleteMedicalRecordProperty(
    Map<String, dynamic> data,
    String id,
  );

  /// 🔹 Update property
  Future<SuccessModel> updateMedicalRecordProperty(
    Map<String, dynamic> data,
    String id,
  );
}
