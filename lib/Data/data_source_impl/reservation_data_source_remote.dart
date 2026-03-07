import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../../index/index_main.dart';

class ReservationRemoteDataSourceImpl implements ReservationRemoteDataSource {
  final FirebaseDatabase _database;

  ReservationRemoteDataSourceImpl(this._database);

  DatabaseReference? _rootRef;
  final List<StreamSubscription> _subscriptions = [];

  // ============================================================
  // 🌊 STREAM CONTROLLERS
  // ============================================================

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
  // 🎧 START LISTENING
  // ============================================================

  @override
  Future<void> startListening({required String doctorKey}) async {
    await stopListening();

    final path = "doctors/$doctorKey/reservations";
    _rootRef = _database.ref(path);

    print("🎧 Listening on → $path");

    final dateSub = _rootRef!.onChildAdded.listen((dateEvent) {
      final dateKey = dateEvent.snapshot.key;
      if (dateKey == null) return;

      print("📅 Date detected → $dateKey");

      // ✅ Build correct reference manually
      final dateRef = _rootRef!.child(dateKey);

      _listenInsideDate(dateRef);
    });

    _subscriptions.add(dateSub);
  }

  // ============================================================
  // 📅 LISTEN INSIDE DATE NODE
  // ============================================================

  void _listenInsideDate(DatabaseReference dateRef) {
    print("📂 Entering date → ${dateRef.key}");

    // ➕ Reservation Added
    final addedSub = dateRef.onChildAdded.listen((event) {
      final key = event.snapshot.key;
      if (key == null) return;

      print("➕ Reservation Added → $key");

      final model = _parseReservation(event.snapshot);
      if (model != null) _addedController.add(model);
    });

    // 🔄 Reservation Updated
    final changedSub = dateRef.onChildChanged.listen((event) {
      final key = event.snapshot.key;
      if (key == null) return;

      print("🔄 Reservation Changed → $key");

      final model = _parseReservation(event.snapshot);
      if (model != null) _changedController.add(model);
    });

    // ❌ Reservation Removed
    final removedSub = dateRef.onChildRemoved.listen((event) {
      final key = event.snapshot.key;
      if (key == null) return;

      print("❌ Reservation Removed → $key");
      _removedController.add(key);
    });

    _subscriptions.addAll([addedSub, changedSub, removedSub]);
  }

  // ============================================================
  // 🧠 PARSE RESERVATION
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
      print("🔥 Parse error → $e");
      return null;
    }
  }

  // ============================================================
  // ☁️ CREATE
  // ============================================================

  @override
  Future<void> createReservation(ReservationModel reservation) async {
    final path = _buildPath(reservation);
    print("☁️ Create → $path");
    await _database.ref(path).set(reservation.toJson());
  }

  // ============================================================
  // 🔄 UPDATE
  // ============================================================

  @override
  Future<void> updateReservation(ReservationModel reservation) async {
    final path = _buildPath(reservation);
    print("☁️ Update → $path");
    await _database.ref(path).update(reservation.toJson());
  }

  // ============================================================
  // ❌ DELETE
  // ============================================================

  @override
  Future<void> deleteReservation(ReservationModel reservation) async {
    final path = _buildPath(reservation);
    print("☁️ Delete → $path");
    await _database.ref(path).remove();
  }

  // ============================================================
  // 🔧 HELPERS
  // ============================================================

  String _buildPath(ReservationModel reservation) {
    final normalizedDate = AppDateFormatter.toDash(
      reservation.appointmentDateTime,
    );

    return "doctors/${reservation.doctorKey}"
        "/reservations/$normalizedDate"
        "/${reservation.key}";
  }

  // ============================================================
  // 🛑 STOP LISTENING
  // ============================================================

  @override
  Future<void> stopListening() async {
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();
    _rootRef = null;

    print("🛑 Listeners stopped");
  }
}
