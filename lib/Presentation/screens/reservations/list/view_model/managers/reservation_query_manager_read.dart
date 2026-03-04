import '../../../../../../index/index_main.dart';

class ReservationQueryManager {
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

    await AuthenticationService().getClientsLocalData(
      isFiltered: false,
      query: SQLiteQueryParams(
        where: "key = ?",
        whereArgs: [patientKey],
        limit: 1,
      ),
      voidCallBack: (List<LocalUser?> clients) {
        if (clients.isNotEmpty) {
          result = clients.first;
        }
      },
    );

    return result;
  }
}
