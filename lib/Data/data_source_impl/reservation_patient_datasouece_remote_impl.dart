import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../../index/index_main.dart';

class PatientReservationRemoteDataSourceImpl
    implements PatientReservationRemoteDataSource {
  final FirebaseDatabase _database;

  PatientReservationRemoteDataSourceImpl(this._database);

  DatabaseReference? _ref;
  final List<StreamSubscription> _subscriptions = [];

  final _addedController = StreamController<ReservationModel>.broadcast();
  final _changedController = StreamController<ReservationModel>.broadcast();
  final _removedController = StreamController<String>.broadcast();

  @override
  Stream<ReservationModel> get onAdded => _addedController.stream;

  @override
  Stream<ReservationModel> get onChanged => _changedController.stream;

  @override
  Stream<String> get onRemoved => _removedController.stream;

  // ============================================================
  // 🚀 START LISTEN
  // ============================================================
  @override
  Future<void> startListening({required String patientUid}) async {
    await stopListening();

    final path = "patients/$patientUid/reservationsMeta";
    _ref = _database.ref(path);

    print("🎧 Patient Listening → $path");

    final addedSub = _ref!.onChildAdded.listen(_onAdded);
    final changedSub = _ref!.onChildChanged.listen(_onChanged);
    final removedSub = _ref!.onChildRemoved.listen(_onRemoved);

    _subscriptions.addAll([addedSub, changedSub, removedSub]);
  }

  // ============================================================
  // 🔥 LISTENERS HANDLERS (clean separation)
  // ============================================================

  void _onAdded(DatabaseEvent event) {
    final key = event.snapshot.key;
    if (key == null) return;

    print("➕ Patient Reservation Added → $key");

    final model = _parseReservation(event.snapshot);
    if (model != null) _addedController.add(model);
  }

  void _onChanged(DatabaseEvent event) {
    final key = event.snapshot.key;
    if (key == null) return;

    print("🔄 Patient Reservation Changed → $key");

    final model = _parseReservation(event.snapshot);
    if (model != null) _changedController.add(model);
  }

  void _onRemoved(DatabaseEvent event) {
    final key = event.snapshot.key;
    if (key == null) return;

    print("❌ Patient Reservation Removed → $key");

    _removedController.add(key);
  }

  // ============================================================
  // 🧩 PARSE
  // ============================================================
  ReservationModel? _parseReservation(DataSnapshot snapshot) {
    final data = snapshot.value;

    if (data == null || data is! Map) return null;

    try {
      final json = Map<String, dynamic>.from(
        data.map((k, v) => MapEntry(k.toString(), v)),
      );

      json['key'] = snapshot.key;

      return ReservationModel.fromJson(json);
    } catch (e) {
      print("🔥 Patient Parse error → $e");
      return null;
    }
  }

  // ============================================================
  // ☁️ CREATE
  // ============================================================
  @override
  Future<void> createReservation(ReservationModel reservation) async {
    final path = _buildPath(reservation);

    print("☁️ Patient Create → $path");

    await _database.ref(path).set(reservation.toJson());
  }

  // ============================================================
  // ☁️ UPDATE
  // ============================================================
  @override
  Future<void> updateReservation(ReservationModel reservation) async {
    final path = _buildPath(reservation);

    print("☁️ Patient Update → $path");

    await _database.ref(path).update(reservation.toJson());
  }

  // ============================================================
  // ☁️ DELETE
  // ============================================================
  @override
  Future<void> deleteReservation(ReservationModel reservation) async {
    final path = _buildPath(reservation);

    print("☁️ Patient Delete → $path");

    await _database.ref(path).remove();
  }

  // ============================================================
  // 📍 PATH
  // ============================================================
  String _buildPath(ReservationModel reservation) {
    final patientUid = reservation.patientUid;
    final key = reservation.key;

    if (patientUid == null || key == null) {
      throw Exception("❌ Missing patientUid or reservation key");
    }

    final path = "patients/$patientUid/reservationsMeta/$key";

    print("📍 Patient Path → $path");

    return path;
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

    print("🛑 Patient Listeners stopped");
  }

  // ============================================================
  // 🧹 DISPOSE (important 🔥)
  // ============================================================
  void dispose() {
    _addedController.close();
    _changedController.close();
    _removedController.close();
  }
}
