import 'dart:async';
import '../../index/index_main.dart';

class PatientReservationService {
  // ============================================================
  // 🧠 SINGLETON
  // ============================================================

  static final PatientReservationService _instance =
      PatientReservationService._internal();

  factory PatientReservationService() => _instance;

  PatientReservationService._internal();

  final PatientReservationUseCases useCase = initController(
    () => PatientReservationUseCases(Get.find()),
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
  String? _currentPatientUid;

  // ============================================================
  // 🔥 START REALTIME
  // ============================================================

  Future<void> startListening({required String patientUid}) async {
    if (patientUid.isEmpty) return;

    if (_isListening) {
      await useCase.stopListening();
    }

    if (_currentPatientUid == patientUid && _isListening) {
      print("🟡 PatientService already listening for this user");
      return;
    }

    if (_isListening) {
      print("🔄 Switching patient → restarting listener");
      await stopListening();
    }

    print("🎧 PatientService START listening → $patientUid");

    await useCase.startListening(patientUid: patientUid);

    _addedSub = useCase.onAdded.listen((reservation) {
      print("📡 Patient Event → ADDED ${reservation.key}");
      onReservationAdded?.call(reservation);
    });

    _changedSub = useCase.onChanged.listen((reservation) {
      print("📡 Patient Event → CHANGED ${reservation.key}");
      onReservationUpdated?.call(reservation);
    });

    _removedSub = useCase.onRemoved.listen((key) {
      print("📡 Patient Event → REMOVED $key");
      onReservationRemoved?.call(key);
    });

    _currentPatientUid = patientUid;
    _isListening = true;

    print("✅ PatientService listening ACTIVE");
  }

  // ============================================================
  // 🛑 STOP
  // ============================================================

  Future<void> stopListening() async {
    print("🛑 PatientService stopListening");

    await _addedSub?.cancel();
    await _changedSub?.cancel();
    await _removedSub?.cancel();

    _addedSub = null;
    _changedSub = null;
    _removedSub = null;

    _isListening = false;
    _currentPatientUid = null;

    await useCase.stopListening();
  }

  // ============================================================
  // ➕ ADD
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
  // 🔄 UPDATE
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
  // ❌ DELETE
  // ============================================================

  Future<void> deleteReservationData({
    required ReservationModel reservation,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    final result = await useCase.deleteReservation(reservation);

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  // ============================================================
  // 🛑 DISPOSE
  // ============================================================

  Future<void> dispose() async {
    print("🛑 PatientService dispose");

    await stopListening();
    await useCase.dispose();
  }
}
