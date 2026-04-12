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

  /// ============================================================
  /// 🔑 Resolve Doctor Key (THE FIX 🔥)
  String _resolveDoctorKey(String? doctorKey) {
    // ============================================================
    // ✅ PRIORITY: PARAM
    // ============================================================

    if (doctorKey != null && doctorKey.isNotEmpty) {
      return doctorKey;
    }

    // ============================================================
    // 🧠 GET SESSION USER
    // ============================================================

    final sessionUser = Get.find<UserSession>().user?.user;

    String? resolvedKey;

    // ============================================================
    // 👨‍⚕️ DOCTOR
    // ============================================================

    if (sessionUser is DoctorUser) {
      resolvedKey = sessionUser.uid;
    }

    // ============================================================
    // 🧑‍⚕️ ASSISTANT
    // ============================================================

    else if (sessionUser is AssistantUser) {
      resolvedKey = sessionUser.doctorKey;
    }

    // ============================================================
    // 🚨 SAFETY CHECK
    // ============================================================

    if (resolvedKey == null || resolvedKey.isEmpty) {
      throw Exception("❌ doctorKey is NULL or EMPTY");
    }

    return resolvedKey;
  }

  /// ============================================================
  /// 🌐 Paths
  /// ============================================================
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

  /// ============================================================
  /// 📥 GET CLINICS
  /// ============================================================
  @override
  Future<List<ClinicModel?>> getClinics(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    String? doctorKey,
    bool? isFiltered, {
    bool? fromOnline,
  }) async {
    try {
      /// 1️⃣ FORCE ONLINE
      if (fromOnline == true) {
        print("🌐 [CLINICS] Force Online Fetch");
        return await _fetchOnlineClinics(data, doctorKey);
      }

      /// 2️⃣ LOCAL FIRST
      final localData = await _sqliteRepo.getAll(query: query);

      /// 3️⃣ FILTER MODE
      if (isFiltered == true) {
        print("📘 [CLINICS] Local Only (Filtered Mode) → ${localData.length}");
        return localData;
      }

      /// 4️⃣ USE LOCAL IF EXISTS
      if (localData.isNotEmpty) {
        print("📘 [CLINICS] Local Loaded → ${localData.length}");
        return localData;
      }

      /// 5️⃣ FETCH ONLINE
      print("🌐 [CLINICS] Local empty → Fetch Online");
      return await _fetchOnlineClinics(data, doctorKey);
    } catch (e) {
      print("❌ getClinics error: $e");
      return [];
    }
  }

  /// ============================================================
  /// 🌐 FETCH ONLINE
  /// ============================================================
  Future<List<ClinicModel?>> _fetchOnlineClinics(
    Map<String, dynamic> params,
    String? doctorKey,
  ) async {
    final path = _clinicsPath(doctorKey);

    print("🌍 API PATH: $path");

    final response = await _clientSourceRepo.request(
      HttpMethod.GET,
      path,
      params: params,
    );

    /// 🔥 handle null (Firebase case)
    if (response == null) {
      print("⚠️ No clinics found (null response)");
      return [];
    }

    final list = handleResponse<ClinicModel>(
      response,
      (json) => ClinicModel.fromJson(json),
    );

    /// 💾 cache locally
    for (var clinic in list) {
      if (clinic?.key?.isNotEmpty == true) {
        await _sqliteRepo.addItem(clinic!);
      }
    }

    return list;
  }

  /// ============================================================
  /// 👤 PATIENT CLINICS
  /// ============================================================
  @override
  Future<List<ClinicModel?>> getClinicsFromPatient(
    Map<String, dynamic> data,
    String? doctorKey,
  ) async {
    try {
      final resolvedKey = _resolveDoctorKey(doctorKey);

      final sqliteData = await _sqliteRepo.getAll(
        query: SQLiteQueryParams(
          is_filtered: true,
          where: "doctor_key = ?",
          whereArgs: [resolvedKey],
        ),
      );

      if (sqliteData.isNotEmpty) return sqliteData;

      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        _patientClinicsPath(resolvedKey),
        params: data,
      );

      final clinicList = handleResponse<ClinicModel>(
        response,
        (json) => ClinicModel.fromJson(json),
      );

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

  /// ============================================================
  /// ➕ ADD
  /// ============================================================
  @override
  Future<SuccessModel> addClinic(
    Map<String, dynamic> data,
    String? doctorKey,
    String key,
  ) async {
    try {
      final resolvedKey = _resolveDoctorKey(doctorKey);

      final clinic = ClinicModel.fromJson(data);

      await _sqliteRepo.addItem(clinic);

      final response = await _clientSourceRepo.request(
        HttpMethod.PATCH,
        _clinicItemPath(resolvedKey, key),
        params: data,
      );

      return SuccessModel.fromJson(response);
    } catch (e) {
      print("❌ addClinic error: $e");
      return SuccessModel(message: "حدث خطأ أثناء إضافة العيادة");
    }
  }

  /// ============================================================
  /// ❌ DELETE
  /// ============================================================
  @override
  Future<SuccessModel> deleteClinic(
    Map<String, dynamic> data,
    String? doctorKey,
    String key,
  ) async {
    try {
      final resolvedKey = _resolveDoctorKey(doctorKey);

      await _sqliteRepo.deleteItem(key);

      final response = await _clientSourceRepo.request(
        HttpMethod.DELETE,
        _clinicItemPath(resolvedKey, key),
        params: data,
      );

      return SuccessModel.fromJson(response ?? {"message": "تم الحذف بنجاح"});
    } catch (e) {
      print("❌ deleteClinic error: $e");
      return SuccessModel(message: "فشل حذف بيانات العيادة");
    }
  }

  /// ============================================================
  /// ✏️ UPDATE
  /// ============================================================
  @override
  Future<SuccessModel> updateClinic(
    Map<String, dynamic> data,
    String? doctorKey,
    String key,
  ) async {
    try {
      final resolvedKey = _resolveDoctorKey(doctorKey);

      final clinic = ClinicModel.fromJson(data);

      await _sqliteRepo.updateItem(clinic);

      final response = await _clientSourceRepo.request(
        HttpMethod.PATCH,
        _clinicItemPath(resolvedKey, key),
        params: data,
      );

      return SuccessModel.fromJson(response);
    } catch (e) {
      print("❌ updateClinic error: $e");
      return SuccessModel(message: "فشل تحديث بيانات العيادة");
    }
  }
}
