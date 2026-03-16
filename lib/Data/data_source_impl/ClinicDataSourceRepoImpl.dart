import '../../index/index_main.dart';

class ClinicDataSourceRepoImpl extends ClinicDataSourceRepo {
  final ClientSourceRepo _clientSourceRepo;

  final BaseSQLiteDataSourceRepo<ClinicModel> _sqliteRepo;

  ClinicDataSourceRepoImpl(this._clientSourceRepo)
    : _sqliteRepo = BaseSQLiteDataSourceRepo<ClinicModel>(
        tableName: "clinics",
        fromJson: (json) => ClinicModel.fromJson(json),
        toJson: (model) => model.toJson(),
        getId: (model) => model.key,
      );

  /// 🔹 Helpers to avoid wrong URL paths
  String _clinicsPath(String? doctorKey) =>
      "/${ApiConstatns.clinics}/$doctorKey/clinics.json";

  String _clinicItemPath(String? doctorKey, String key) =>
      "/${ApiConstatns.clinics}/$doctorKey/clinics/$key.json";

  String _patientClinicsPath(String? doctorKey) =>
      "/${ApiConstatns.clinics_patient}/$doctorKey/clinics.json";

  @override
  Future<List<ClinicModel?>> getClinics(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    String? doctorKey,
    bool? isFiltered, {
    bool? fromOnline,
  }) async {
    try {
      /// --------------------------------------------------------
      /// 1️⃣ FORCE ONLINE
      /// --------------------------------------------------------
      if (fromOnline == true) {
        print("🌐 [CLINICS] Force Online Fetch");
        return await _fetchOnlineClinics(data, doctorKey);
      }

      /// --------------------------------------------------------
      /// 2️⃣ LOCAL FIRST
      /// --------------------------------------------------------
      final localData = await _sqliteRepo.getAll(query: query);

      /// --------------------------------------------------------
      /// 3️⃣ FILTER MODE → ALWAYS RETURN LOCAL
      /// --------------------------------------------------------
      if (isFiltered == true) {
        print("📘 [CLINICS] Local Only (Filtered Mode) → ${localData.length}");
        return localData;
      }

      /// --------------------------------------------------------
      /// 4️⃣ IF LOCAL HAS DATA → USE IT
      /// --------------------------------------------------------
      if (localData.isNotEmpty) {
        print("📘 [CLINICS] Local Loaded → ${localData.length}");
        return localData;
      }

      /// --------------------------------------------------------
      /// 5️⃣ LOCAL EMPTY → FETCH ONLINE & SAVE
      /// --------------------------------------------------------
      print("🌐 [CLINICS] Local empty → Fetch Online");
      return await _fetchOnlineClinics(data, doctorKey);
    } catch (e) {
      print("❌ getClinics error: $e");
      return [];
    }
  }

  /// 🔹 Fetch clinics from API
  Future<List<ClinicModel?>> _fetchOnlineClinics(
    Map<String, dynamic> params,
    String? doctorKey,
  ) async {
    final response = await _clientSourceRepo.request(
      HttpMethod.GET,
      _clinicsPath(doctorKey),
      params: params,
    );

    final list = handleResponse<ClinicModel>(
      response,
      (json) => ClinicModel.fromJson(json),
    );

    /// 🔥 Save locally
    for (var clinic in list) {
      if (clinic?.key?.isNotEmpty == true) {
        await _sqliteRepo.addItem(clinic!);
      }
    }

    return list;
  }

  @override
  Future<List<ClinicModel?>> getClinicsFromPatient(
    Map<String, dynamic> data,
    String? doctorKey,
  ) async {
    try {
      /// 🔥 Try Local First
      final sqliteData = await _sqliteRepo.getAll(
        query: SQLiteQueryParams(
          is_filtered: true,
          where: "doctor_key = ?",
          whereArgs: [doctorKey],
        ),
      );

      if (sqliteData.isNotEmpty) return sqliteData;

      /// 🔥 Load from API
      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        _patientClinicsPath(doctorKey),
        params: data,
      );

      List<ClinicModel?> clinicList = handleResponse<ClinicModel>(
        response,
        (json) => ClinicModel.fromJson(json),
      );

      /// 🔥 Cache locally
      for (final clinic in clinicList) {
        if (clinic?.key?.isNotEmpty == true) {
          await _sqliteRepo.addItem(clinic!);
        }
      }

      return clinicList;
    } catch (e) {
      print("❌ getClinicsFromPatient error: $e");
      return [];
    }
  }

  @override
  Future<SuccessModel> addClinic(
    Map<String, dynamic> data,
    String? doctorKey,
    String key,
  ) async {
    try {
      final clinic = ClinicModel.fromJson(data);

      /// 🔥 Save Local
      await _sqliteRepo.addItem(clinic);

      /// 🔥 Sync API
      final response = await _clientSourceRepo.request(
        HttpMethod.PATCH,
        _clinicItemPath(doctorKey, key),
        params: data,
      );

      return SuccessModel.fromJson(response);
    } catch (e) {
      print("❌ addClinic error: $e");
      return SuccessModel(message: "حدث خطأ أثناء إضافة العيادة");
    }
  }

  @override
  Future<SuccessModel> deleteClinic(
    Map<String, dynamic> data,
    String? doctorKey,
    String key,
  ) async {
    try {
      /// 🔥 Delete Local
      await _sqliteRepo.deleteItem(key);

      /// 🔥 Delete API
      final response = await _clientSourceRepo.request(
        HttpMethod.DELETE,
        _clinicItemPath(doctorKey, key),
        params: data,
      );

      return SuccessModel.fromJson(response ?? {"message": "تم الحذف بنجاح"});
    } catch (e) {
      print("❌ deleteClinic error: $e");
      return SuccessModel(message: "فشل حذف بيانات العيادة");
    }
  }

  @override
  Future<SuccessModel> updateClinic(
    Map<String, dynamic> data,
    String? doctorKey,
    String key,
  ) async {
    try {
      final clinic = ClinicModel.fromJson(data);

      /// 🔥 Update Local
      await _sqliteRepo.updateItem(clinic);

      /// 🔥 Update API
      final response = await _clientSourceRepo.request(
        HttpMethod.PATCH,
        _clinicItemPath(doctorKey, key),
        params: data,
      );

      return SuccessModel.fromJson(response);
    } catch (e) {
      print("❌ updateClinic error: $e");
      return SuccessModel(message: "فشل تحديث بيانات العيادة");
    }
  }
}
