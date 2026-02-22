import '../../../../../../index/index_main.dart';

class ReservationQueryManager {
  /// 🔹 Generic fetch
  Future<List<ReservationModel>> getReservations({
    required String? appointmentDate,
    required SQLiteQueryParams query,
    bool isFiltered = false,
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

  // ------------------------------------------------------------
  Future<List<ReservationModel>> fetchByDateClinicAndShift({
    required String? appointmentDate,
    required ClinicModel? selectedClinic,
    required GenericListModel? selectedShift,
    bool isFiltered = false,
    bool? fromOnline,
  }) async {
    if (appointmentDate == null ||
        selectedClinic == null ||
        selectedShift == null) {
      return [];
    }

    String where =
        "appointment_date_time = ? AND clinic_key = ? AND shift_key = ?";
    final whereArgs = <Object?>[
      appointmentDate,
      selectedClinic.key,
      selectedShift.key,
    ];

    return await getReservations(
      appointmentDate: appointmentDate,
      query: SQLiteQueryParams(
        is_filtered: true,
        where: where,
        whereArgs: whereArgs,
        orderBy: "order_num ASC",
      ),
      isFiltered: isFiltered,
      fromOnline: fromOnline,
    );
  }

  // ------------------------------------------------------------
  Future<List<ReservationModel>> fetchAllReservationsOfDay({
    required String? appointmentDate,
    required ClinicModel? selectedClinic,
    required GenericListModel? selectedShift,
    bool isFiltered = false,
    bool? fromOnline,
  }) async {
    return await fetchByDateClinicAndShift(
      appointmentDate: appointmentDate,
      selectedClinic: selectedClinic,
      selectedShift: selectedShift,
      isFiltered: isFiltered,
      fromOnline: fromOnline,
    );
  }

  // ------------------------------------------------------------
  Future<int> getTotalByDate({
    required String? appointmentDate,
    required ClinicModel? selectedClinic,
    required GenericListModel? selectedShift,
    bool isFiltered = false,
    bool? fromOnline,
  }) async {
    if (appointmentDate == null ||
        selectedClinic == null ||
        selectedShift == null) {
      return 0;
    }

    int count = 0;

    await ReservationService().getReservationsData(
      date: appointmentDate,
      data: FirebaseFilter(),
      query: SQLiteQueryParams(
        is_filtered: true,
        where: "appointment_date_time = ? AND clinic_key = ? AND shift_key = ?",
        whereArgs: [appointmentDate, selectedClinic.key, selectedShift.key],
      ),
      fromOnline: fromOnline,
      voidCallBack: (list) {
        count = list.length;
      },
    );

    return count;
  }

  // ------------------------------------------------------------
  Future<List<ReservationModel>> getCompletedReservationsForReport({
    required String? appointmentDate,
    required ClinicModel? selectedClinic,
    required GenericListModel? selectedShift,
    bool isFiltered = false,
    bool? fromOnline,
  }) async {
    if (appointmentDate == null ||
        selectedClinic == null ||
        selectedShift == null) {
      return [];
    }

    return await getReservations(
      appointmentDate: appointmentDate,
      query: SQLiteQueryParams(
        is_filtered: true,
        where:
            "appointment_date_time = ? AND clinic_key = ? AND shift_key = ? AND status = ?",
        whereArgs: [
          appointmentDate,
          selectedClinic.key,
          selectedShift.key,
          ReservationStatus.completed.value,
        ],
        orderBy: "order_num ASC",
      ),
      isFiltered: isFiltered,
      fromOnline: fromOnline,
    );
  }

  // ------------------------------------------------------------
  Future<ReservationModel?> getLastCompletedForPatient(
    String patientKey, {
    bool isFiltered = false,
    bool? fromOnline,
  }) async {
    ReservationModel? result;

    await ReservationService().getReservationsData(
      data: FirebaseFilter(),
      query: SQLiteQueryParams(
        is_filtered: isFiltered,
        where: "patient_key = ? AND status = ?",
        whereArgs: [patientKey, ReservationStatus.completed.value],
        orderBy: "create_at DESC",
        limit: 1,
      ),
      fromOnline: fromOnline,
      voidCallBack: (list) {
        if (list.isNotEmpty) {
          result = list.first as ReservationModel;
        }
      },
    );

    return result;
  }

  // ------------------------------------------------------------
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
