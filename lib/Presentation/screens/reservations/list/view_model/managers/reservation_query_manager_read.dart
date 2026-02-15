import '../../../../../../index/index_main.dart';

class ReservationQueryManager {
  // Generic fetch using ready SQLiteQueryParams
  Future<List<ReservationModel>> getReservations({
    required String? appointmentDate,
    required SQLiteQueryParams query,
    bool? fromOnline,
  }) async {
    if (appointmentDate == null) return [];

    List<ReservationModel> result = [];

    await ReservationService().getReservationsData(
      date: appointmentDate,
      data: FirebaseFilter(),
      query: query,
      fromOnline: fromOnline,
      voidCallBack: (list) {
        result = list.whereType<ReservationModel>().toList();
      },
    );

    return result;
  }

  // Fetch reservations by date and clinic
  Future<List<ReservationModel>> fetchByDateAndClinic({
    required String? appointmentDate,
    required ClinicModel? selectedClinic,
  }) async {
    if (appointmentDate == null) return [];

    String where = "appointment_date_time = ?";
    final whereArgs = <Object?>[appointmentDate];

    if (selectedClinic?.key != null) {
      where += " AND clinic_key = ?";
      whereArgs.add(selectedClinic!.key);
    }

    return await getReservations(
      appointmentDate: appointmentDate,
      query: SQLiteQueryParams(
        is_filtered: true,
        where: where,
        whereArgs: whereArgs,
        orderBy: "order_num ASC",
      ),
    );
  }

  // Fetch all reservations of the day
  Future<List<ReservationModel>> fetchAllReservationsOfDay({
    required String? appointmentDate,
    required ClinicModel? selectedClinic,
  }) async {
    return await fetchByDateAndClinic(
      appointmentDate: appointmentDate,
      selectedClinic: selectedClinic,
    );
  }

  // Get total reservations count for a specific date
  Future<int> getTotalByDate({required String? appointmentDate}) async {
    if (appointmentDate == null) return 0;

    int count = 0;

    await ReservationService().getReservationsData(
      date: appointmentDate,
      data: FirebaseFilter(),
      query: SQLiteQueryParams(
        is_filtered: true,
        where: "appointment_date_time = ?",
        whereArgs: [appointmentDate],
      ),
      voidCallBack: (list) {
        count = list.length;
      },
    );

    return count;
  }

  // Get completed reservations for report
  Future<List<ReservationModel>> getCompletedReservationsForReport({
    required String? appointmentDate,
  }) async {
    if (appointmentDate == null) return [];
    return await getReservations(
      appointmentDate: appointmentDate,
      query: SQLiteQueryParams(
        is_filtered: true,
        where: "appointment_date_time = ? AND status = ?",
        whereArgs: [appointmentDate, ReservationStatus.completed.value],
      ),
    );
  }

  // Get last completed reservation for a patient
  Future<ReservationModel?> getLastCompletedForPatient(
    String patientKey,
  ) async {
    ReservationModel? result;

    await ReservationService().getReservationsData(
      data: FirebaseFilter(),
      query: SQLiteQueryParams(
        is_filtered: false,
        where: "patient_key = ? AND status = ?",
        whereArgs: [patientKey, ReservationStatus.completed.value],
        orderBy: "create_at DESC",
        limit: 1,
      ),
      voidCallBack: (list) {
        if (list.isNotEmpty) {
          result = list.first as ReservationModel;
        }
      },
    );

    return result;
  }

  // Get patient by key
  Future<LocalUser?> getPatientByKey(String patientKey) async {
    LocalUser? result;

    await AuthenticationService().getClientsLocalData(
      isFiltered: false,
      query: SQLiteQueryParams(
        is_filtered: false,
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
