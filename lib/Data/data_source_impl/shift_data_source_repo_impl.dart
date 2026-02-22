import '../../index/index_main.dart';

class ShiftDataSourceRepoImpl extends ShiftDataSourceRepo {
  final ClientSourceRepo _clientSourceRepo;

  final BaseSQLiteDataSourceRepo<ShiftModel> _sqliteRepo;

  ShiftDataSourceRepoImpl(this._clientSourceRepo)
      : _sqliteRepo = BaseSQLiteDataSourceRepo<ShiftModel>(
    tableName: "shifts",
    fromJson: (json) => ShiftModel.fromJson(json),
    toJson: (model) => model.toJson(),
    getId: (model) => model.key,
  );

  // =========================================================
  // 🔹 GET SHIFTS
  // =========================================================
  @override
  Future<List<ShiftModel?>> getShifts(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered, {
        bool? fromOnline,
      }) async {
    try {
      // 🔵 1️⃣ FORCE ONLINE
      if (fromOnline == true) {
        print("🌐 [SHIFTS] Force Online Fetch");
        return await _fetchOnlineAndCache(data);
      }

      // 🔵 2️⃣ LOCAL FIRST
      final localData = await _sqliteRepo.getAll(query: query);

      // 🔵 3️⃣ FILTER MODE → LOCAL ONLY
      if (isFiltered == true) {
        print("📘 [SHIFTS] Local Only (Filtered Mode) → ${localData.length}");
        return localData;
      }

      // 🔵 4️⃣ IF LOCAL EXISTS → RETURN
      if (localData.isNotEmpty) {
        print("📘 [SHIFTS] Local Loaded → ${localData.length}");
        return localData;
      }

      // 🔵 5️⃣ LOCAL EMPTY → FETCH ONLINE
      print("🌐 [SHIFTS] Local empty → Fetch Online");
      return await _fetchOnlineAndCache(data);
    } catch (e) {
      print("❌ getShifts error: $e");
      return [];
    }
  }

  // =========================================================
  // 🔹 FETCH ONLINE + CACHE
  // =========================================================
  Future<List<ShiftModel?>> _fetchOnlineAndCache(
      Map<String, dynamic> params,
      ) async {
    final response = await _clientSourceRepo.request(
      HttpMethod.GET,
      "/${ApiConstatns.shifts}.json",
      params: params,
    );

    final list = handleResponse<ShiftModel>(
      response,
          (json) => ShiftModel.fromJson(json),
    );

    // 🔥 Cache locally (Replace if exists)
    for (final shift in list) {
      if (shift?.key?.isNotEmpty == true) {
        await _sqliteRepo.addItem(shift!);
      }
    }

    return list;
  }

  // =========================================================
  // 🔹 GET SHIFTS FROM PATIENT
  // =========================================================
  @override
  Future<List<ShiftModel?>> getShiftssFromPatient(
      Map<String, dynamic> data,
      String? doctorKey,
      ) async {
    try {
      if (doctorKey == null || doctorKey.isEmpty) return [];

      // 🔵 Try Local First
      final localData = await _sqliteRepo.getAll(
        query: SQLiteQueryParams(
          is_filtered: true,
          where: "doctor_key = ?",
          whereArgs: [doctorKey],
        ),
      );

      if (localData.isNotEmpty) {
        print("📘 [SHIFTS] Local Patient Data Loaded");
        return localData;
      }

      // 🔵 Fetch Online
      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        "/${ApiConstatns.shiftsFromPatient}$doctorKey/shifts.json",
        params: data,
      );

      final shifts = handleResponse<ShiftModel>(
        response,
            (json) => ShiftModel.fromJson(json),
      );

      // 🔥 Cache locally
      for (final shift in shifts) {
        if (shift?.key?.isNotEmpty == true) {
          await _sqliteRepo.addItem(shift!);
        }
      }

      return shifts;
    } catch (e) {
      print("❌ getShiftssFromPatient error: $e");
      return [];
    }
  }

  // =========================================================
  // 🔹 ADD SHIFT
  // =========================================================
  @override
  Future<SuccessModel> addShift(Map<String, dynamic> data, String key) async {
    try {
      final shift = ShiftModel.fromJson(data);

      // 🔥 Save Local
      await _sqliteRepo.addItem(shift);

      // 🔥 Sync Online
      final response = await _clientSourceRepo.request(
        HttpMethod.PATCH,
        "/${ApiConstatns.shifts}/$key.json",
        params: data,
      );

      return SuccessModel.fromJson(response);
    } catch (e) {
      print("❌ addShift error: $e");
      return SuccessModel(message: "حدث خطأ أثناء إضافة الفترة");
    }
  }

  // =========================================================
  // 🔹 DELETE SHIFT
  // =========================================================
  @override
  Future<SuccessModel> deleteShift(
      Map<String, dynamic> data,
      String key,
      ) async {
    try {
      // 🔥 Delete Local
      await _sqliteRepo.deleteItem(key);

      // 🔥 Delete Online
      final response = await _clientSourceRepo.request(
        HttpMethod.DELETE,
        "/${ApiConstatns.shifts}/$key.json",
        params: data,
      );

      return SuccessModel.fromJson(response ?? {"message": "تم الحذف بنجاح"});
    } catch (e) {
      print("❌ deleteShift error: $e");
      return SuccessModel(message: "فشل حذف الفترة");
    }
  }

  // =========================================================
  // 🔹 UPDATE SHIFT
  // =========================================================
  @override
  Future<SuccessModel> updateShift(
      Map<String, dynamic> data,
      String key,
      ) async {
    try {
      final shift = ShiftModel.fromJson(data);

      // 🔥 Update Local
      await _sqliteRepo.updateItem(shift);

      // 🔥 Update Online
      final response = await _clientSourceRepo.request(
        HttpMethod.PATCH,
        "/${ApiConstatns.shifts}/$key.json",
        params: data,
      );

      return SuccessModel.fromJson(response);
    } catch (e) {
      print("❌ updateShift error: $e");
      return SuccessModel(message: "فشل تحديث بيانات الفترة");
    }
  }
}