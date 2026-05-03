import 'dart:async';

import '../../index/index_main.dart';

class PatientOrderService {
  // ============================================================
  // 🧠 SINGLETON
  // ============================================================

  static final PatientOrderService _instance = PatientOrderService._internal();

  factory PatientOrderService() => _instance;

  PatientOrderService._internal();

  final PatientOrderUseCases useCase = initController(
    () => PatientOrderUseCases(Get.find()),
  );

  // ============================================================
  // 🎧 REALTIME CALLBACKS
  // ============================================================

  Function(OrderModel order)? onOrderAdded;
  Function(OrderModel order)? onOrderUpdated;
  Function(String key)? onOrderRemoved;

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

    // 🧠 نفس منطق reservations
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

    _addedSub = useCase.onAdded.listen((order) {
      
      onOrderAdded?.call(order);
    });

    _changedSub = useCase.onChanged.listen((order) {
      onOrderUpdated?.call(order);
    });

    _removedSub = useCase.onRemoved.listen((key) {
      onOrderRemoved?.call(key);
    });

    _currentPatientUid = patientUid;
    _isListening = true;
  } // ============================================================
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

  Future<void> addOrderData({
    required OrderModel order,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    final result = await useCase.addOrder(order);

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  // ============================================================
  // 🔄 UPDATE
  // ============================================================

  Future<void> updateOrderData({
    required OrderModel order,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    final result = await useCase.updateOrder(order);

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  // ============================================================
  // ❌ DELETE
  // ============================================================

  Future<void> deleteOrderData({
    required OrderModel order,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    final result = await useCase.deleteOrder(order);

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
