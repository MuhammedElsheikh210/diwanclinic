import '../../../../../../index/index_main.dart';

class ReservationQueryManager {
  Future<List<ReservationModel>> getReservations({
    required SQLiteQueryParams query,
  }) async {
    List<ReservationModel> result = [];

    // 🧾 DEBUG LOGS
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

  // ------------------------------------------------------------

  Future<List<ReservationModel>> fetchByDateAndClinic({
    required String? appointmentDate,
    required ClinicModel? selectedClinic,
    required String? shiftKey,
  }) async {
    if (appointmentDate == null || shiftKey == null) return [];

    String where = "appointment_date_time = ? AND shift_key = ?";
    final whereArgs = <Object?>[appointmentDate, shiftKey];

    if (selectedClinic?.key != null) {
      where += " AND clinic_key = ?";
      whereArgs.add(selectedClinic!.key);
    }

    return await getReservations(
      query: SQLiteQueryParams(
        where: where,
        whereArgs: whereArgs,
        orderBy: "order_num ASC",
      ),
    );
  }

  // ------------------------------------------------------------

  Future<int> getTotalByDate({
    required String? appointmentDate,
    required String? shiftKey,
  }) async {
    if (appointmentDate == null || shiftKey == null) return 0;

    final list = await getReservations(
      query: SQLiteQueryParams(
        where: "appointment_date_time = ? AND shift_key = ?",
        whereArgs: [appointmentDate, shiftKey],
      ),
    );

    return list.length;
  }

  // ------------------------------------------------------------

  Future<List<ReservationModel>> getCompletedReservationsForReport({
    required String? appointmentDate,
    required String? shiftKey,
  }) async {
    if (appointmentDate == null || shiftKey == null) return [];

    return await getReservations(
      query: SQLiteQueryParams(
        where: "appointment_date_time = ? AND shift_key = ? AND status = ?",
        whereArgs: [
          appointmentDate,
          shiftKey,
          ReservationStatus.completed.value,
        ],
      ),
    );
  }

  // ------------------------------------------------------------

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

  // ------------------------------------------------------------
  // 🔹 Get Patient By Key (Local Only)
  // ------------------------------------------------------------

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
