import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
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

    const path = "orders/";
    _ref = _database.ref(path);

    final addedSub = _ref!.onChildAdded.listen(_onAdded);
    final changedSub = _ref!.onChildChanged.listen(_onChanged);
    final removedSub = _ref!.onChildRemoved.listen(_onRemoved);

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

    // ✅ نفس الفلترة (مهم جدًا)
    if (model.patientuid != _currentPatientUid) return;

    _changedController.add(model);
  }

  void _onRemoved(DatabaseEvent event) {
    final key = event.snapshot.key;

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
