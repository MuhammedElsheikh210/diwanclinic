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
      
      return;
    }

    if (_isListening) {
      
      await stopListening();
    }

    

    await useCase.startListening(patientUid: patientUid);

    _addedSub = useCase.onAdded.listen((reservation) {
      
      onReservationAdded?.call(reservation);
    });

    _changedSub = useCase.onChanged.listen((reservation) {
      
      onReservationUpdated?.call(reservation);
    });

    _removedSub = useCase.onRemoved.listen((key) {
      
      onReservationRemoved?.call(key);
    });

    _currentPatientUid = patientUid;
    _isListening = true;

    
  }

  // ============================================================
  // 🛑 STOP
  // ============================================================

  Future<void> stopListening() async {
    

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
    

    await stopListening();
    await useCase.dispose();
  }
}
