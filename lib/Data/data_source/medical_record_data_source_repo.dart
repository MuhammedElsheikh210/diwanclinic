import '../../index/index_main.dart';

abstract class MedicalRecordDataSourceRepo {
  /// 🔹 Get medical records
  Future<List<MedicalRecordModel?>> getMedicalRecords(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  );

  /// 🔹 Get single medical record
  Future<MedicalRecordModel> getMedicalRecord(Map<String, dynamic> data);

  /// 🔹 Add medical record
  Future<SuccessModel> addMedicalRecord(Map<String, dynamic> data, String id);

  /// 🔹 Delete medical record
  Future<SuccessModel> deleteMedicalRecord(
    Map<String, dynamic> data,
    String id,
  );

  /// 🔹 Update medical record
  Future<SuccessModel> updateMedicalRecord(
    Map<String, dynamic> data,
    String id,
  );
}
