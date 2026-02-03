// ignore_for_file: avoid_renaming_method_parameters
import '../../index/index_main.dart';

class ReservationService {
  final ReservationUseCases useCase = initController(
    () => ReservationUseCases(Get.find()),
  );

  // =========================
  // Async helper: get patient meta as Future
  // =========================
  Future<List<ReservationModel>> getPatientMetaAsync(String patientKey) async {
    final result = await useCase.getPatientReservationsMeta(patientKey);
    return result.fold((l) => <ReservationModel>[], (r) => r);
  }

  // ===========================================================================
  // 🔹 1) Add Reservation
  // ===========================================================================
  Future<void> addReservationData({
    required ReservationModel reservation,
    required String date,
    required Function(ResponseStatus) voidCallBack,
    bool localOnly = false,
    bool isPatient = false,
    String? doctorUid,
  }) async {
    Loader.show();

    final result = await useCase.addReservation(
      reservation,
      date,
      localOnly: localOnly,
      isPatient: isPatient,
      doctorUid: doctorUid,
    );

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  // ===========================================================================
  // 🔹 2) Update Reservation
  // ===========================================================================
  Future<void> updateReservationData({
    required ReservationModel reservation,
    required String date,
    required Function(ResponseStatus) voidCallBack,
    bool localOnly = false,
    bool isPatient = false,
    String? doctorUid,
  }) async {
    Loader.show();

    final result = await useCase.updateReservation(
      reservation,
      localOnly: localOnly,
      date: date,
      isPatient: isPatient,
      doctorUid: doctorUid,
    );

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  // ===========================================================================
  // 🔹 3) Delete Reservation
  // ===========================================================================
  Future<void> deleteReservationData({
    required String reservationKey,
    required String date,
    required Function(ResponseStatus) voidCallBack,
    bool isPatient = false,
    String? doctorUid,
  }) async {
    Loader.show();

    final result = await useCase.deleteReservation(
      reservationKey,
      date,
      isPatient: isPatient,
      doctorUid: doctorUid,
    );

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  // ===========================================================================
  // 🔹 4) Get Reservations
  // ===========================================================================
  Future<void> getReservationsData({
    required FirebaseFilter data,
    required SQLiteQueryParams query,
    bool? fromOnline,
    String? date,
    required Function(List<ReservationModel?>) voidCallBack,
    bool isPatient = false,
    String? doctorUid,
  }) async {
    final result = await useCase.getReservations(
      data,
      query,
      fromOnline,
      date ?? "",
      isPatient: isPatient,
      doctorUid: doctorUid,
    );

    result.fold(
      (l) => Loader.showError("حدث خطأ أثناء جلب البيانات"),
      (r) => voidCallBack(r),
    );
  }

  // ===========================================================================
  // ⭐ NEW — 6) Add Patient Reservation Meta
  // ===========================================================================
  Future<void> addPatientReservationMeta({
    required ReservationModel meta,
    required String patientKey,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();

    final result = await useCase.addPatientReservationMeta(meta, patientKey);

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  // ===========================================================================
  // ⭐ NEW — 7) Get Patient Reservation Meta List
  // ===========================================================================
  Future<void> getPatientReservationsMeta({
    required String patientKey,
    required Function(List<ReservationModel>) voidCallBack,
  }) async {
    final result = await useCase.getPatientReservationsMeta(patientKey);

    result.fold(
      (l) => Loader.showError("فشل تحميل حجوزات المريض"),
      (r) => voidCallBack(r),
    );
  }

  // ===========================================================================
  // ⭐ NEW — 8) UPDATE Patient Reservation Meta (ONLINE ONLY)
  // ===========================================================================
  Future<void> updatePatientReservationData({
    required ReservationModel data,
    required String key,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();

    final result = await useCase.updatePatientReservation(data, key);

    Loader.dismiss();

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }
}
