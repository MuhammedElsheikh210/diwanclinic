
import '../../index/index_main.dart';

class ArchivePatientDataSourceRepoImpl
    extends ArchivePatientDataSourceRepo {
  final ClientSourceRepo _clientSourceRepo;

  ArchivePatientDataSourceRepoImpl(this._clientSourceRepo);

  /// ================= GET ALL ARCHIVE PATIENTS =================

  @override
  Future<List<ArchivePatientModel>> getArchivePatients(
      Map<String, dynamic> data,
      ) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        "/${ApiConstatns.archivePatients}.json",
        params: data,
      );

      if (response == null) return [];

      final Map<String, dynamic> jsonMap =
      Map<String, dynamic>.from(response);

      final List<ArchivePatientModel> archivePatients = [];

      jsonMap.forEach((id, value) {
        final archiveJson = Map<String, dynamic>.from(value);

        archivePatients.add(
          ArchivePatientModel.fromJson(
            id,
            archiveJson,
          ),
        );
      });

      return archivePatients;
    } catch (e) {
      print("❌ [ArchivePatient] Get archive patients failed: $e");
      return [];
    }
  }

  /// ================= GET SINGLE ARCHIVE PATIENT =================

  @override
  Future<ArchivePatientModel> getArchivePatient(
      String archiveId,
      ) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        "/${ApiConstatns.archivePatients}/$archiveId.json",
      );

      return ArchivePatientModel.fromJson(
        archiveId,
        Map<String, dynamic>.from(response),
      );
    } catch (e) {
      print("❌ [ArchivePatient] Get archive patient failed: $e");
      rethrow;
    }
  }

  /// ================= CREATE ARCHIVE PATIENT =================

  @override
  Future<SuccessModel> createArchivePatient(
      Map<String, dynamic> data,
      ) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.POST,
        "/${ApiConstatns.archivePatients}.json",
        params: data,
      );

      return SuccessModel.fromJson(response);
    } catch (e) {
      print("❌ [ArchivePatient] Create archive patient failed: $e");
      return SuccessModel(message: "Create archive patient failed");
    }
  }

  /// ================= UPDATE ARCHIVE PATIENT =================

  @override
  Future<SuccessModel> updateArchivePatient(
      String archiveId,
      Map<String, dynamic> data,
      ) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.PATCH,
        "/${ApiConstatns.archivePatients}/$archiveId.json",
        params: data,
      );

      return SuccessModel.fromJson(response);
    } catch (e) {
      print("❌ [ArchivePatient] Update archive patient failed: $e");
      return SuccessModel(message: "Update archive patient failed");
    }
  }

  /// ================= DELETE ARCHIVE PATIENT =================

  @override
  Future<SuccessModel> deleteArchivePatient(
      String archiveId,
      ) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.DELETE,
        "/${ApiConstatns.archivePatients}/$archiveId.json",
      );

      return response == null
          ? SuccessModel(message: "Archive patient deleted successfully")
          : SuccessModel.fromJson(response);
    } catch (e) {
      print("❌ [ArchivePatient] Delete archive patient failed: $e");
      return SuccessModel(message: "Delete archive patient failed");
    }
  }
}
