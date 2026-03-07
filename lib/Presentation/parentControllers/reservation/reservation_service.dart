// ignore_for_file: avoid_renaming_method_parameters

import 'dart:async';
import '../../../index/index_main.dart';

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
  // 🎧 REALTIME CALLBACKS (For ViewModels)
  // ============================================================

  Function(ReservationModel reservation)? onReservationAdded;
  Function(ReservationModel reservation)? onReservationUpdated;
  Function(String key)? onReservationRemoved;

  StreamSubscription? _addedSub;
  StreamSubscription? _changedSub;
  StreamSubscription? _removedSub;

  bool _isListening = false;

  // ============================================================
  // 🔥 START REALTIME SYNC (Firebase → SQLite → UI)
  // ============================================================

  Future<void> startListening({required String doctorKey}) async {
    if (_isListening) {
      print("🟡 ReservationService already listening — skip");
      return;
    }

    print("🎧 ReservationService START listening");

    await useCase.startListening(doctorKey: doctorKey);

    // 👂 Listen to realtime events from UseCases
    _addedSub = useCase.onAdded.listen((reservation) {
      print("📡 Service Event → ADDED ${reservation.key}");
      onReservationAdded?.call(reservation);
    });

    _changedSub = useCase.onChanged.listen((reservation) {
      print("📡 Service Event → CHANGED ${reservation.key}");
      onReservationUpdated?.call(reservation);
    });

    _removedSub = useCase.onRemoved.listen((key) {
      print("📡 Service Event → REMOVED $key");
      onReservationRemoved?.call(key);
    });

    _isListening = true;

    print("✅ ReservationService listening ACTIVE");
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
  // ⭐ PATIENT META
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
  // 🛑 STOP REALTIME SYNC
  // ============================================================

  Future<void> dispose() async {
    print("🛑 ReservationService dispose");

    _isListening = false;

    await _addedSub?.cancel();
    await _changedSub?.cancel();
    await _removedSub?.cancel();

    _addedSub = null;
    _changedSub = null;
    _removedSub = null;

    await useCase.dispose();
  }
}
