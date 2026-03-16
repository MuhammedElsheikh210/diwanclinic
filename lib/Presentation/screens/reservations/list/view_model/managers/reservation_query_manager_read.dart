import '../../../../../../index/index_main.dart';

class ReservationQueryManager {
  // ============================================================
  // 🔹 Base Query Executor
  // ============================================================

  Future<List<ReservationModel>> getReservations({
    required SQLiteQueryParams query,
  }) async {
    List<ReservationModel> result = [];

    print("══════════════════════════════");
    print("📥 Reservation Query Params:");
    print("➡️ WHERE     : ${query.where}");
    print("➡️ WHERE ARGS: ${query.whereArgs}");
    print("➡️ ORDER BY  : ${query.orderBy}");
    print("➡️ LIMIT     : ${query.limit}");
    print("══════════════════════════════");

    await ReservationService().getReservationsData(
      query: query,
      voidCallBack: (list) {
        result = list.whereType<ReservationModel>().toList();
        print("📦 Result Count: ${result.length}");
      },
    );

    return result;
  }

  // ============================================================
  // 🔹 Fetch Daily Reservations (Dynamic Filtering)
  // ============================================================

  Future<List<ReservationModel>> fetchByDateAndClinic({
    required String? appointmentDate,
    required ClinicModel? selectedClinic,
    required String? shiftKey,
    String? medicalCenterKey,
  }) async {
    if (appointmentDate == null || shiftKey == null) return [];

    String where = "appointment_date_time = ? AND shift_key = ?";
    final whereArgs = <Object?>[appointmentDate, shiftKey];

    // ✅ فلترة حسب العيادة لو موجودة
    if (selectedClinic?.key != null && selectedClinic!.key!.isNotEmpty) {
      where += " AND clinic_key = ?";
      whereArgs.add(selectedClinic.key);
    }

    // ✅ فلترة حسب المركز الطبي لو موجود
    if (medicalCenterKey != null && medicalCenterKey.isNotEmpty) {
      where += " AND medical_center_key = ?";
      whereArgs.add(medicalCenterKey);
    }

    return await getReservations(
      query: SQLiteQueryParams(
        where: where,
        whereArgs: whereArgs,
        orderBy: "order_num ASC",
      ),
    );
  }

  // ============================================================
  // 🔹 Total Reservations (Dynamic Filtering)
  // ============================================================

  Future<int> getTotalByDate({
    required String? appointmentDate,
    required String? shiftKey,
    ClinicModel? selectedClinic,
    String? medicalCenterKey,
  }) async {
    if (appointmentDate == null || shiftKey == null) return 0;
    print("get total key");
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

    final list = await getReservations(
      query: SQLiteQueryParams(where: where, whereArgs: whereArgs),
    );

    return list.length;
  }

  // ============================================================
  // 🔹 Completed Reservations For Report (Dynamic Filtering)
  // ============================================================

  Future<List<ReservationModel>> getCompletedReservationsForReport({
    required String? appointmentDate,
    required String? shiftKey,
    ClinicModel? selectedClinic,
    String? medicalCenterKey,
  }) async {
    if (appointmentDate == null || shiftKey == null) return [];

    String where =
        "appointment_date_time = ? AND shift_key = ? AND status = ?";
    final whereArgs = <Object?>[
      appointmentDate,
      shiftKey,
      ReservationStatus.completed.value,
    ];

    if (selectedClinic?.key != null && selectedClinic!.key!.isNotEmpty) {
      where += " AND clinic_key = ?";
      whereArgs.add(selectedClinic.key);
    }

    if (medicalCenterKey != null && medicalCenterKey.isNotEmpty) {
      where += " AND medical_center_key = ?";
      whereArgs.add(medicalCenterKey);
    }

    return await getReservations(
      query: SQLiteQueryParams(where: where, whereArgs: whereArgs),
    );
  }

  // ============================================================
  // 🔹 Last Completed Reservation For Patient
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