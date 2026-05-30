import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../../index/index_main.dart';

class PatientOrderRemoteDataSourceImpl implements PatientOrderRemoteDataSource {
  final FirebaseDatabase _database;

  PatientOrderRemoteDataSourceImpl(this._database);

  DatabaseReference? _ref;
  final List<StreamSubscription> _subscriptions = [];

  // ✅ مهم
  String? _currentPatientUid;

  final _addedController = StreamController<OrderModel>.broadcast();
  final _changedController = StreamController<OrderModel>.broadcast();
  final _removedController = StreamController<String>.broadcast();

  @override
  Stream<OrderModel> get onAdded => _addedController.stream;

  @override
  Stream<OrderModel> get onChanged => _changedController.stream;

  @override
  Stream<String> get onRemoved => _removedController.stream;

  // ============================================================
  // 🚀 START LISTENING
  // ============================================================

  @override
  Future<void> startListening({required String patientUid}) async {
    await stopListening();

    _currentPatientUid = patientUid;

    _ref = _database.ref("orders");

    // بنسمع على كل الـ orders بدون query عشان onChildChanged يشتغل صح
    // لو استخدمنا orderByChild().equalTo() من غير Firebase index
    // onChildChanged مش بيشتغل لما حقل تاني غير المفلتر عليه بيتغير (زي status)
    // الفلترة بتحصل client-side في _onAdded / _onChanged
    void onError(Object error, StackTrace stack) {
      AppLogger.error("ORDER_DS", "Stream error", error, stack);
    }

    final addedSub = _ref!.onChildAdded.listen(_onAdded, onError: onError, cancelOnError: false);
    final changedSub = _ref!.onChildChanged.listen(_onChanged, onError: onError, cancelOnError: false);
    final removedSub = _ref!.onChildRemoved.listen(_onRemoved, onError: onError, cancelOnError: false);

    _subscriptions.addAll([addedSub, changedSub, removedSub]);
  }

  // ============================================================
  // 🔥 HANDLERS
  // ============================================================

  void _onAdded(DatabaseEvent event) {
    final model = _parseOrder(event.snapshot);

    if (model == null) return;

    if (model.patientuid != _currentPatientUid) return;

    _addedController.add(model);
  }

  void _onChanged(DatabaseEvent event) {
    final model = _parseOrder(event.snapshot);

    if (model == null) return;

    debugPrint('[ORDER_SYNC] _onChanged fired → key=${model.key} status=${model.status} patientuid=${model.patientuid} | currentUid=$_currentPatientUid');

    if (model.patientuid != _currentPatientUid) {
      debugPrint('[ORDER_SYNC] ❌ filtered out (patientuid mismatch)');
      return;
    }

    debugPrint('[ORDER_SYNC] ✅ passed filter → pushing to stream');
    _changedController.add(model);
  }

  void _onRemoved(DatabaseEvent event) {
    final key = event.snapshot.key;
    debugPrint('[ORDER_SYNC] _onRemoved fired → key=$key | currentUid=$_currentPatientUid');

    if (key != null) {
      _removedController.add(key);
    }
  }

  // ============================================================
  // 🧩 PARSE
  // ============================================================

  OrderModel? _parseOrder(DataSnapshot snapshot) {
    final data = snapshot.value;

    if (data == null || data is! Map) return null;

    try {
      final json = Map<String, dynamic>.from(
        data.map((k, v) => MapEntry(k.toString(), v)),
      );

      json['key'] = snapshot.key;

      return OrderModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // ☁️ CREATE
  // ============================================================

  @override
  Future<void> createOrder(OrderModel order) async {
    final path = _buildPath(order);
    await _database.ref(path).set(order.toJson());
  }

  // ============================================================
  // ☁️ UPDATE
  // ============================================================

  @override
  Future<void> updateOrder(OrderModel order) async {
    final path = _buildPath(order);
    await _database.ref(path).update(order.toJson());
  }

  // ============================================================
  // ☁️ DELETE
  // ============================================================

  @override
  Future<void> deleteOrder(OrderModel order) async {
    final path = _buildPath(order);
    await _database.ref(path).remove();
  }

  // ============================================================
  // 📍 PATH (🔥 FIXED)
  // ============================================================

  String _buildPath(OrderModel order) {
    final key = order.key;

    if (key == null) {
      throw Exception("❌ Missing order key");
    }

    return "orders/$key";
  }

  // ============================================================
  // 🛑 STOP
  // ============================================================

  @override
  Future<void> stopListening() async {
    for (final sub in _subscriptions) {
      await sub.cancel();
    }

    _subscriptions.clear();
    _ref = null;
    _currentPatientUid = null;
  }

  // ============================================================
  // 🧹 DISPOSE
  // ============================================================

  void dispose() {
    _addedController.close();
    _changedController.close();
    _removedController.close();
  }
}
