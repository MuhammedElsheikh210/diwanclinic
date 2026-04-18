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
  // 🔥 Unified Query (FIXED + DEBUGGED)
  // ============================================================

  Future<List<ReservationModel>> getByFilters({
    required String? appointmentDate,
    required String? shiftKey,
    ClinicModel? selectedClinic,
    String? medicalCenterKey,
  }) async {

    if (appointmentDate == null || shiftKey == null) {
      return [];
    }

    /// ✅ 🔥 أهم سطر في الكلاس كله
    final normalizedDate = AppDateFormatter.normalize(appointmentDate);


    // ============================================================
    // 🔍 DEBUG STEP 1: Fetch All Data
    // ============================================================

    final allData = await getReservations(
      query: SQLiteQueryParams(where: "1=1"),
    );


    for (var r in allData.take(5)) {
    }

    // ============================================================
    // 🔍 DEBUG STEP 2: Shift Only
    // ============================================================

    final shiftOnly = await getReservations(
      query: SQLiteQueryParams(where: "shift_key = ?", whereArgs: [shiftKey]),
    );


    // ============================================================
    // 🔍 DEBUG STEP 3: Date Only
    // ============================================================

    final dateOnly = await getReservations(
      query: SQLiteQueryParams(
        where: "appointment_date_time LIKE ?",
        whereArgs: ["%$normalizedDate%"],
      ),
    );


    // ============================================================
    // 🔥 FINAL QUERY
    // ============================================================

    String where = "appointment_date_time = ? AND shift_key = ?";
    final whereArgs = <Object?>[normalizedDate, shiftKey];

    if (selectedClinic?.key != null && selectedClinic!.key!.isNotEmpty) {
      where += " AND clinic_key = ?";
      whereArgs.add(selectedClinic.key);
    }

    if (medicalCenterKey != null && medicalCenterKey.isNotEmpty) {
      where += " AND medical_center_key = ?";
      whereArgs.add(medicalCenterKey);
    }


    final result = await getReservations(
      query: SQLiteQueryParams(
        where: where,
        whereArgs: whereArgs,
        orderBy: "order_num ASC",
      ),
    );


    // ============================================================
    // 🔥 EXTRA DEBUG (Manual Filter Check)
    // ============================================================

    final manualCheck =
        allData.where((r) {
          return r.appointmentDateTime == normalizedDate &&
              r.shiftKey == shiftKey &&
              r.clinicKey == selectedClinic?.key;
        }).toList();


    return result;
  }

  // ============================================================
  // 🔹 Last Completed Reservation For Patient
  // ============================================================

  Future<ReservationModel?> getLastCompletedForPatient(
    String patientKey,
  ) async {
    final list = await getReservations(
      query: SQLiteQueryParams(
        where: "patient_uid = ? AND status = ?",
        whereArgs: [patientKey, ReservationStatus.completed.value],
        orderBy: "created_at DESC",
        limit: 1,
      ),
    );

    return list.isNotEmpty ? list.first : null;
  }

  // ============================================================
  // 🔹 Get Patient By Key
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
