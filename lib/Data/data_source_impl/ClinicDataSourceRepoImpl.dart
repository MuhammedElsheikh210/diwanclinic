import '../../index/index_main.dart';

class ClinicDataSourceRepoImpl extends ClinicDataSourceRepo {
  final ClientSourceRepo _clientSourceRepo;

  ClinicDataSourceRepoImpl(this._clientSourceRepo);

  // ============================================================
  // 🔑 Resolve Doctor Key
  // ============================================================

  String _resolveDoctorKey(String? doctorKey) {
    if (doctorKey != null && doctorKey.isNotEmpty) {
      return doctorKey;
    }

    final sessionUser = Get.find<UserSession>().user?.user;

    if (sessionUser is DoctorUser) {
      return sessionUser.uid ?? "";
    } else if (sessionUser is AssistantUser) {
      return sessionUser.doctorKey ?? "";
    }

    throw Exception("❌ doctorKey is NULL or EMPTY");
  }

  // ============================================================
  // 🌐 Paths
  // ============================================================

  String _clinicsPath(String? doctorKey) {
    final key = _resolveDoctorKey(doctorKey);
    return "/${ApiConstatns.clinics}/$key/clinics.json";
  }

  String _clinicItemPath(String? doctorKey, String key) {
    final resolvedKey = _resolveDoctorKey(doctorKey);
    return "/${ApiConstatns.clinics}/$resolvedKey/clinics/$key.json";
  }

  String _patientClinicsPath(String? doctorKey) {
    final resolvedKey = _resolveDoctorKey(doctorKey);
    return "/${ApiConstatns.clinics_patient}/$resolvedKey/clinics.json";
  }

  // ============================================================
  // 📥 GET CLINICS (ONLINE ONLY)
  // ============================================================

  @override
  Future<List<ClinicModel?>> getClinics(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    String? doctorKey,
    bool? isFiltered, {
    bool? fromOnline,
  }) async {
    try {
      final path = _clinicsPath(doctorKey);


      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        path,
        params: data,
      );

      if (response == null || response.isEmpty) {
        return [];
      }

      return handleResponse<ClinicModel>(
        response,
        (json) => ClinicModel.fromJson(json),
      );
    } catch (e) {
      return [];
    }
  }

  // ============================================================
  // 👤 PATIENT CLINICS (ONLINE ONLY)
  // ============================================================

  @override
  Future<List<ClinicModel?>> getClinicsFromPatient(
    Map<String, dynamic> data,
    String? doctorKey,
  ) async {
    try {
      final path = _patientClinicsPath(doctorKey);


      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        path,
        params: data,
      );

      if (response == null || response.isEmpty) {
        return [];
      }

      return handleResponse<ClinicModel>(
        response,
        (json) => ClinicModel.fromJson(json),
      );
    } catch (e) {
      return [];
    }
  }

  // ============================================================
  // ➕ ADD (ONLINE ONLY)
  // ============================================================

  @override
  Future<SuccessModel> addClinic(
    Map<String, dynamic> data,
    String? doctorKey,
    String key,
  ) async {
    try {
      final path = _clinicItemPath(doctorKey, key);


      final response = await _clientSourceRepo.request(
        HttpMethod.PATCH,
        path,
        params: data,
      );

      return SuccessModel.fromJson(response);
    } catch (e) {
      return SuccessModel(message: "حدث خطأ أثناء إضافة العيادة");
    }
  }

  // ============================================================
  // ❌ DELETE (ONLINE ONLY)
  // ============================================================

  @override
  Future<SuccessModel> deleteClinic(
    Map<String, dynamic> data,
    String? doctorKey,
    String key,
  ) async {
    try {
      final path = _clinicItemPath(doctorKey, key);


      final response = await _clientSourceRepo.request(
        HttpMethod.DELETE,
        path,
        params: data,
      );

      return SuccessModel.fromJson(response ?? {"message": "تم الحذف بنجاح"});
    } catch (e) {
      return SuccessModel(message: "فشل حذف العيادة");
    }
  }

  // ============================================================
  // ✏️ UPDATE (ONLINE ONLY)
  // ============================================================

  @override
  Future<SuccessModel> updateClinic(
    Map<String, dynamic> data,
    String? doctorKey,
    String key,
  ) async {
    try {
      final path = _clinicItemPath(doctorKey, key);


      final response = await _clientSourceRepo.request(
        HttpMethod.PATCH,
        path,
        params: data,
      );

      return SuccessModel.fromJson(response);
    } catch (e) {
      return SuccessModel(message: "فشل تحديث العيادة");
    }
  }
}
