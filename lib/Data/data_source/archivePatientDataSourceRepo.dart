import '../../index/index_main.dart';

abstract class ArchivePatientDataSourceRepo {
  /// 🔍 Get all archive records for a patient
  Future<List<ArchivePatientModel>> getArchivePatients(
      Map<String, dynamic> data,
      );

  /// 📌 Get single archive record
  Future<ArchivePatientModel> getArchivePatient(
      String archiveId,
      );

  /// ➕ Create new archive record
  Future<SuccessModel> createArchivePatient(
      Map<String, dynamic> data,
      );

  /// 🔄 Update archive record
  Future<SuccessModel> updateArchivePatient(
      String archiveId,
      Map<String, dynamic> data,
      );

  /// 🗑 Delete archive record
  Future<SuccessModel> deleteArchivePatient(
      String archiveId,
      );
}
