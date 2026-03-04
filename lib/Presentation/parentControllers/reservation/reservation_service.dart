// ignore_for_file: avoid_renaming_method_parameters
import '../../../index/index_main.dart';

class ReservationService {
  final ReservationUseCases useCase = initController(
    () => ReservationUseCases(Get.find()),
  );

  // ============================================================
  // 🔥 START REALTIME LISTENING (Reservations Only)
  // ============================================================

  void startListening({
    required String doctorKey,
    required String date,
    required Function(ReservationModel model) onChanged,
    required Function(String key) onRemoved,
    VoidCallback? onInitialLoadComplete,
  }) {
    bool _firstBatch = true;

    useCase.startListening(
      doctorKey: doctorKey,
      date: date,
      onChanged: (model) {
        if (_firstBatch) {
          _firstBatch = false;
          onInitialLoadComplete?.call(); // 🔥 أول ما الداتا الأولى تخلص
          return;
        }

        onChanged(model);
      },
      onRemoved: (key) {
        if (_firstBatch) return;
        onRemoved(key);
      },
    );
  }

  // ============================================================
  // 🔹 ADD RESERVATION (Optimistic)
  // ============================================================

  Future<void> addReservationData({
    required ReservationModel reservation,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    final result = await useCase.addReservation(reservation);

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  // ============================================================
  // 🔹 UPDATE RESERVATION (Optimistic)
  // ============================================================

  Future<void> updateReservationData({
    required ReservationModel reservation,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    final result = await useCase.updateReservation(reservation);

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  // ============================================================
  // 🔹 DELETE RESERVATION (Soft Delete)
  // ============================================================

  Future<void> deleteReservationData({
    required String reservationKey,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    final result = await useCase.deleteReservation(reservationKey);

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  // ============================================================
  // 🔹 GET RESERVATIONS (Always Local)
  // ============================================================

  Future<void> getReservationsData({
    required SQLiteQueryParams query,
    required Function(List<ReservationModel?>) voidCallBack,
  }) async {
    final result = await useCase.getReservations(query);

    result.fold(
      (l) => Loader.showError("حدث خطأ أثناء جلب البيانات"),
      (r) => voidCallBack(r),
    );
  }

  // ============================================================
  // ⭐ PATIENT META (Remote Direct)
  // ============================================================

  Future<void> addPatientReservationMeta({
    required ReservationModel meta,
    required String patientKey,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    final result = await useCase.addPatientReservationMeta(meta, patientKey);

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  Future<void> updatePatientReservationData({
    required ReservationModel data,
    required String key,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    final result = await useCase.updatePatientReservation(data, key);

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

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

  // 🔹 Helper (Async direct return)
  Future<List<ReservationModel>> getPatientMetaAsync(String patientKey) async {
    final result = await useCase.getPatientReservationsMeta(patientKey);

    return result.fold((l) => <ReservationModel>[], (r) => r);
  }

  // ============================================================
  // 🔹 CLEAR LOCAL (Debug only)
  // ============================================================

  Future<void> clearLocalReservations() async {
    final db = await DatabaseService().database;
    await db.delete("reservations");
  }

  // ============================================================
  // 🔥 STOP LISTENING
  // ============================================================

  void dispose() {
    useCase.dispose();
  }
}
