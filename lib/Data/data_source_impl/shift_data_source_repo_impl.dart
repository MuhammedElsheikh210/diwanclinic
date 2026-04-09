import '../../index/index_main.dart';

class ShiftDataSourceRepoImpl extends ShiftDataSourceRepo {
  final ClientSourceRepo _clientSourceRepo;

  ShiftDataSourceRepoImpl(this._clientSourceRepo);

  /// ============================================================
  /// 🔑 Resolve Doctor Key (FIX 🔥)
  /// ============================================================
  String _resolveDoctorKey(String? doctorKey) {
    if (doctorKey != null && doctorKey.isNotEmpty) {
      return doctorKey;
    }

    final user = LocalUser().getUserData();

    final resolvedKey = user.userType?.name == "doctor"
        ? user.uid
        : user.doctorKey;

    print("👤 userType: ${user.userType?.name}");
    print("🔑 user.key: ${user.key}");
    print("🔑 user.doctorKey: ${user.doctorKey}");
    print("🔑 FINAL doctorKey: $resolvedKey");

    if (resolvedKey == null || resolvedKey.isEmpty) {
      throw Exception("❌ doctorKey is NULL or EMPTY");
    }

    return resolvedKey;
  }

  /// ============================================================
  /// 🌐 Paths
  /// ============================================================
  String _shiftsPath(String? doctorKey) {
    final key = _resolveDoctorKey(doctorKey);
    return "/${ApiConstatns.shifts}/$key/shifts.json";
  }

  String _shiftItemPath(String? doctorKey, String key) {
    final resolvedKey = _resolveDoctorKey(doctorKey);
    return "/${ApiConstatns.shifts}/$resolvedKey/shifts/$key.json";
  }

  String _shiftsPatientPath(String? doctorKey) {
    final key = _resolveDoctorKey(doctorKey);
    return "/${ApiConstatns.shiftsFromPatient}/$key/shifts.json";
  }

  /// ============================================================
  /// 🕒 Get shifts (Doctor)
  /// ============================================================
  @override
  Future<List<ShiftModel?>> getShifts(
      Map<String, dynamic> data,
      String? doctorKey,
      ) async {
    try {
      final path = _shiftsPath(doctorKey);

      print("🌍 SHIFTS API PATH: $path");

      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        path,
        params: data,
      );

      if (response == null || response.isEmpty) {
        print("⚠️ No shifts found");
        return [];
      }

      return handleResponse<ShiftModel>(
        response,
            (json) => ShiftModel.fromJson(json),
      );
    } catch (e) {
      print("❌ getShifts error: $e");
      return [];
    }
  }

  /// ============================================================
  /// 👨‍⚕️ Get shifts (Patient)
  /// ============================================================
  @override
  Future<List<ShiftModel?>> getShiftsFromPatient(
      Map<String, dynamic> data,
      String? doctorKey,
      ) async {
    try {
      final path = _shiftsPatientPath(doctorKey);

      print("🌍 SHIFTS PATIENT API PATH: $path");

      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        path,
        params: data,
      );

      if (response == null || response.isEmpty) {
        print("⚠️ No patient shifts found");
        return [];
      }

      return handleResponse<ShiftModel>(
        response,
            (json) => ShiftModel.fromJson(json),
      );
    } catch (e) {
      print("❌ getShiftsFromPatient error: $e");
      return [];
    }
  }

  /// ============================================================
  /// ➕ Add Shift
  /// ============================================================
  @override
  Future<SuccessModel> addShift(
      Map<String, dynamic> data,
      String key,
      String? doctorKey,
      ) async {
    try {
      final path = _shiftItemPath(doctorKey, key);

      print("➕ ADD SHIFT PATH: $path");

      final response = await _clientSourceRepo.request(
        HttpMethod.PATCH,
        path,
        params: data,
      );

      return SuccessModel.fromJson(response);
    } catch (e) {
      print("❌ addShift error: $e");
      return SuccessModel(message: "حدث خطأ أثناء إضافة الفترة");
    }
  }

  /// ============================================================
  /// ❌ Delete Shift
  /// ============================================================
  @override
  Future<SuccessModel> deleteShift(
      Map<String, dynamic> data,
      String key,
      String? doctorKey,
      ) async {
    try {
      final path = _shiftItemPath(doctorKey, key);

      print("❌ DELETE SHIFT PATH: $path");

      final response = await _clientSourceRepo.request(
        HttpMethod.DELETE,
        path,
        params: data,
      );

      return SuccessModel.fromJson(
        response ?? {"message": "تم الحذف بنجاح"},
      );
    } catch (e) {
      print("❌ deleteShift error: $e");
      return SuccessModel(message: "فشل حذف الفترة");
    }
  }

  /// ============================================================
  /// ✏️ Update Shift
  /// ============================================================
  @override
  Future<SuccessModel> updateShift(
      Map<String, dynamic> data,
      String key,
      String? doctorKey,
      ) async {
    try {
      final path = _shiftItemPath(doctorKey, key);

      print("✏️ UPDATE SHIFT PATH: $path");

      final response = await _clientSourceRepo.request(
        HttpMethod.PATCH,
        path,
        params: data,
      );

      return SuccessModel.fromJson(response);
    } catch (e) {
      print("❌ updateShift error: $e");
      return SuccessModel(message: "فشل تحديث بيانات الفترة");
    }
  }
}