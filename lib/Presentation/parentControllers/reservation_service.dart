// ignore_for_file: avoid_renaming_method_parameters

import 'dart:async';
import '../../index/index_main.dart';

class ReservationService {
  // ============================================================
  // 🧠 SINGLETON
  // ============================================================

  static final ReservationService _instance = ReservationService._internal();

  factory ReservationService() => _instance;

  ReservationService._internal();

  final ReservationUseCases useCase = initController(
    () => ReservationUseCases(Get.find()),
  );

  // ============================================================
  // 🎧 REALTIME CALLBACKS
  // ============================================================

  Function(ReservationModel reservation)? onReservationAdded;
  Function(ReservationModel reservation)? onReservationUpdated;
  Function(String key)? onReservationRemoved;

  StreamSubscription? _addedSub;
  StreamSubscription? _changedSub;
  StreamSubscription? _removedSub;

  bool _isListening = false;
  String? _currentDoctorKey;
  String? _currentDate;
  Timer? _reconnectTimer;

  // ============================================================
  // 🔥 START REALTIME SYNC
  // ============================================================

  Future<void> startListening({
    required String doctorKey,
    required String date,
  }) async {
    if (doctorKey.isEmpty || date.isEmpty) return;

    // نفس الدكتور ونفس التاريخ وبيسمع فعلاً - مش محتاج نعمل حاجة
    if (_currentDoctorKey == doctorKey && _currentDate == date && _isListening) {
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    if (_isListening) {
      await stopListening();
    }

    await useCase.startListening(doctorKey: doctorKey, date: date);

    void onStreamError(Object error, StackTrace stack) {
      AppLogger.error("RESERVATION_SERVICE", "Stream error — scheduling reconnect", error, stack);
      _scheduleReconnect(doctorKey: doctorKey, date: date);
    }

    _addedSub = useCase.onAdded.listen(
      (reservation) => onReservationAdded?.call(reservation),
      onError: onStreamError,
      cancelOnError: false,
    );

    _changedSub = useCase.onChanged.listen(
      (reservation) => onReservationUpdated?.call(reservation),
      onError: onStreamError,
      cancelOnError: false,
    );

    _removedSub = useCase.onRemoved.listen(
      (key) => onReservationRemoved?.call(key),
      onError: onStreamError,
      cancelOnError: false,
    );

    _currentDoctorKey = doctorKey;
    _currentDate = date;
    _isListening = true;
  }

  void _scheduleReconnect({required String doctorKey, required String date}) {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () async {
      AppLogger.info("RESERVATION_SERVICE", "Reconnecting realtime...");
      _isListening = false;
      _currentDoctorKey = null;
      _currentDate = null;
      await startListening(doctorKey: doctorKey, date: date);
    });
  }

  // ============================================================
  // 🛑 STOP REALTIME ONLY
  // ============================================================

  Future<void> stopListening() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    _isListening = false;
    _currentDoctorKey = null;
    _currentDate = null;

    await _addedSub?.cancel();
    await _changedSub?.cancel();
    await _removedSub?.cancel();

    _addedSub = null;
    _changedSub = null;
    _removedSub = null;

    await useCase.stopListening();
  }

  // ============================================================
  // 🔹 ADD RESERVATION
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
  // 🔹 UPDATE RESERVATION
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
  // 🔹 DELETE RESERVATION
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
  // 🔹 GET RESERVATIONS (LOCAL)
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
  // 📥 GET RESERVATIONS (REMOTE - PATIENT)
  // ============================================================

  Future<void> fetchReservationsOnce({
    required String doctorKey,
    required String date, // yyyy-MM-dd
    required Function(List<ReservationModel>) voidCallBack,
  }) async {
    final result = await useCase.fetchReservationsOnce(
      doctorKey: doctorKey,
      date: date,
    );

    result.fold(
      (l) {
        Loader.showError("حدث خطأ أثناء جلب الحجوزات");
      },
      (r) {
        voidCallBack(r);
      },
    );
  }

  // ============================================================
  // ⭐ PATIENT META
  // ============================================================

  // Future<void> addPatientReservationMeta({
  //   required ReservationModel meta,
  //   required String patientKey,
  //   required Function(ResponseStatus) voidCallBack,
  // }) async {
  //   final result = await useCase.addPatientReservationMeta(meta, patientKey);
  //
  //   result.fold(
  //     (l) => voidCallBack(ResponseStatus.error),
  //     (r) => voidCallBack(ResponseStatus.success),
  //   );
  // }
  //
  // Future<void> updatePatientReservationData({
  //   required ReservationModel data,
  //   required String key,
  //   required Function(ResponseStatus) voidCallBack,
  // }) async {
  //   final result = await useCase.updatePatientReservation(data, key);
  //
  //   result.fold(
  //     (l) => voidCallBack(ResponseStatus.error),
  //     (r) => voidCallBack(ResponseStatus.success),
  //   );
  // }
  //
  // Future<void> getPatientReservationsMeta({
  //   required String patientKey,
  //   required Function(List<ReservationModel>) voidCallBack,
  // }) async {
  //   final result = await useCase.getPatientReservationsMeta(patientKey);
  //
  //   result.fold(
  //     (l) => Loader.showError("فشل تحميل حجوزات المريض"),
  //     (r) => voidCallBack(r),
  //   );
  // }
  //
  // Future<List<ReservationModel>> getPatientMetaAsync(String patientKey) async {
  //   final result = await useCase.getPatientReservationsMeta(patientKey);
  //   return result.fold((l) => <ReservationModel>[], (r) => r);
  // }

  // ============================================================
  // 🔹 CLEAR LOCAL
  // ============================================================

  Future<void> clearLocalReservations() async {
    final db = await DatabaseService().database;
    await db.delete("reservations");
  }

  // ============================================================
  // 🛑 DISPOSE SERVICE
  // ============================================================

  Future<void> dispose() async {

    await stopListening();

    await useCase.dispose();
  }
}
