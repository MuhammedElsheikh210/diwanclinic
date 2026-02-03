import '../../index/index_main.dart';

abstract class ReservationDataSourceRepo {
  // ------------------------------------------------------------
  // 📌 Main Reservations (Doctor Side)
  // ------------------------------------------------------------

  Future<List<ReservationModel?>> getReservations(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? fromOnline,
    bool? isFiltered,
    String date, {
    bool isPatient = false,
    String? doctorUid,
  });

  Future<SuccessModel> addReservation(
    Map<String, dynamic> data,
    String key,
    String date, {
    bool localOnly = false,
    bool isPatient = false,
    String? doctorUid,
  });

  Future<SuccessModel> deleteReservation(
    Map<String, dynamic> data,
    String key,
    String date, {
    bool isPatient = false,
    String? doctorUid,
  });

  Future<SuccessModel> updateReservation(
    Map<String, dynamic> data,
    String key,
    String date, {
    bool localOnly = false,
    bool isPatient = false,
    String? doctorUid,
  });

  // ------------------------------------------------------------
  // ⭐ NEW: Patient Reservation META (Used in Patient App)
  // ------------------------------------------------------------

  /// ➕ Add patient reservation metadata (date + doctor uid + type + key)
  Future<SuccessModel> addPatientReservationMeta(
    ReservationModel meta,
    String patientKey,
  );

  /// 🔍 Get all patient reservation metadata
  Future<List<ReservationModel>> getPatientReservationsMeta(String patientKey);

  Future<SuccessModel> updatePatientReservation(
    ReservationModel meta,
    String key,
  );
}
