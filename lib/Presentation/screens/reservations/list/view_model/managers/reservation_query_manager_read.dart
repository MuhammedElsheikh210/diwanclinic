import '../../../../../../index/index_main.dart';

class ReservationQueryManager {
  // ============================================================
  // 🔹 Base Query Executor
  // ============================================================

  Future<List<ReservationModel>> getReservations({
    required SQLiteQueryParams query,
  }) async {
    List<ReservationModel> result = [];

    await ReservationService().getReservationsData(
      query: query,
      voidCallBack: (list) {
        result = list.whereType<ReservationModel>().toList();
      },
    );

    return result;
  }

  // ============================================================
  // 🔥 Unified Query
  // ============================================================

  Future<List<ReservationModel>> getByFilters({
    required String? appointmentDate,
    required String? shiftKey,
    ClinicModel? selectedClinic,
    String? medicalCenterKey,
  }) async {
    print("📅 appointmentDate: $appointmentDate");
    print("⏰ shiftKey: $shiftKey");
    print("🏥 clinicKey: ${selectedClinic?.key}");
    print("🏢 medicalCenterKey: $medicalCenterKey");

    if (appointmentDate == null || shiftKey == null) {
      print("❌ Missing filters");
      return [];
    }

    /// 🔥 1) شوف كل الداتا الأول (بدون فلترة)
    final allData = await getReservations(
      query: SQLiteQueryParams(
        where: "1=1",
      ),
    );

    print("📦 ALL DATA COUNT: ${allData.length}");

    for (var r in allData.take(5)) {
      print("👉 RAW ITEM:");
      print("   date: ${r.appointmentDateTime}");
      print("   shift: ${r.shiftKey}");
      print("   clinic: ${r.clinicKey}");
      print("----------------------");
    }

    /// 🔥 2) جرب فلترة بالـ shift بس
    final shiftOnly = await getReservations(
      query: SQLiteQueryParams(
        where: "shift_key = ?",
        whereArgs: [shiftKey],
      ),
    );

    print("🧪 SHIFT ONLY COUNT: ${shiftOnly.length}");

    /// 🔥 3) جرب فلترة بالـ date بس (LIKE)
    final dateOnly = await getReservations(
      query: SQLiteQueryParams(
        where: "appointment_date_time LIKE ?",
        whereArgs: ["%$appointmentDate%"],
      ),
    );

    print("🧪 DATE ONLY COUNT: ${dateOnly.length}");

    /// 🔥 4) الفلتر الحالي
    String where = "appointment_date_time = ? AND shift_key = ?";
    final whereArgs = <Object?>[appointmentDate, shiftKey];

    if (selectedClinic?.key != null && selectedClinic!.key!.isNotEmpty) {
      where += " AND clinic_key = ?";
      whereArgs.add(selectedClinic.key);
    }

    if (medicalCenterKey != null && medicalCenterKey.isNotEmpty) {
      where += " AND medical_center_key = ?";
      whereArgs.add(medicalCenterKey);
    }

    print("🧠 FINAL QUERY:");
    print("WHERE: $where");
    print("ARGS: $whereArgs");

    final result = await getReservations(
      query: SQLiteQueryParams(
        where: where,
        whereArgs: whereArgs,
        orderBy: "order_num ASC",
      ),
    );

    print("✅ FINAL RESULT COUNT: ${result.length}");

    return result;
  }

  // ============================================================
  // 🔹 Last Completed Reservation For Patient (نسيبها زي ما هي)
  // ============================================================

  Future<ReservationModel?> getLastCompletedForPatient(
    String patientKey,
  ) async {
    final list = await getReservations(
      query: SQLiteQueryParams(
        where: "patient_key = ? AND status = ?",
        whereArgs: [patientKey, ReservationStatus.completed.value],
        orderBy: "create_at DESC",
        limit: 1,
      ),
    );

    return list.isNotEmpty ? list.first : null;
  }

  // ============================================================
  // 🔹 Get Patient By Key (دي مختلفة فسيبها)
  // ============================================================

  Future<LocalUser?> getPatientByKey(String patientKey) async {
    LocalUser? result;

    await AuthenticationService().getClientsData(
      query: SQLiteQueryParams(
        where: "key = ?",
        whereArgs: [patientKey],
        limit: 1,
      ),
      voidCallBack: (clients) {
        if (clients.isNotEmpty && clients.first != null) {
          result = clients.first;
        }
      },
    );

    return result;
  }
}
