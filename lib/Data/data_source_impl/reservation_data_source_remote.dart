import 'dart:async';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:diwanclinic/Data/data_source/reservation_remote_date_source.dart';
import '../../index/index_main.dart';

class ReservationRemoteDataSourceImpl implements ReservationRemoteDataSource {
  final FirebaseDatabase _database;

  ReservationRemoteDataSourceImpl(this._database);

  final List<StreamSubscription> _subscriptions = [];

  DatabaseReference? _currentRef;

  // ============================================================
  // 🔥 LISTEN (LOAD EXISTING + REALTIME)
  // ============================================================

  @override
  Future<void> listenToReservations({
    required String doctorKey,
    required String date,
    required Function(ReservationModel model) onAdded,
    required Function(ReservationModel model) onChanged,
    required Function(String key) onRemoved,
  }) async {
    await stopListening();

    final path = "doctors/$doctorKey/reservations";
    _currentRef = _database.ref(path);

    debugPrint("🎧 Listening Path → $path");

    try {
      final snapshot = await _currentRef!.get();

      if (snapshot.exists) {
        for (final dateNode in snapshot.children) {
          _listenToDateNode(dateNode.ref, onAdded, onChanged, onRemoved);

          for (final reservationNode in dateNode.children) {
            final model = _mapSnapshot(reservationNode);
            if (model != null) {
              debugPrint("📥 Reservation Loaded → ${model.key}");

              onAdded(model);
            }
          }
        }
      }
    } catch (e) {
      debugPrint("⚠️ Initial load failed: $e");
    }

    /// listen when new date is created
    final sub = _currentRef!.onChildAdded.listen((event) {
      final dateRef = event.snapshot.ref;

      _listenToDateNode(dateRef, onAdded, onChanged, onRemoved);

      for (final reservationNode in event.snapshot.children) {
        final model = _mapSnapshot(reservationNode);
        if (model != null) {
          onAdded(model);
        }
      }
    });

    _subscriptions.add(sub);
  }

  // ============================================================
  // 🔥 LISTEN TO RESERVATIONS INSIDE DATE
  // ============================================================

  void _listenToDateNode(
    DatabaseReference dateRef,
    Function(ReservationModel model) onAdded,
    Function(ReservationModel model) onChanged,
    Function(String key) onRemoved,
  ) {
    final addedSub = dateRef.onChildAdded.listen((event) {
      final model = _mapSnapshot(event.snapshot);
      if (model != null) {
        onAdded(model);
      }
    });

    final changedSub = dateRef.onChildChanged.listen((event) {
      final model = _mapSnapshot(event.snapshot);
      if (model != null) {
        onChanged(model);
      }
    });

    final removedSub = dateRef.onChildRemoved.listen((event) {
      final key = event.snapshot.key;
      if (key != null) {
        onRemoved(key);
      }
    });

    _subscriptions.addAll([addedSub, changedSub, removedSub]);
  }

  // ============================================================
  // ⚡ CREATE
  // ============================================================

  @override
  Future<void> createReservation(ReservationModel reservation) async {
    final path = _buildPath(reservation);

    debugPrint("⬆️ CREATE → $path");

    await _database.ref(path).set(reservation.toJson());
  }

  // ============================================================
  // 🔄 UPDATE
  // ============================================================

  @override
  Future<void> updateReservation(ReservationModel reservation) async {
    final path = _buildPath(reservation);

    debugPrint("🔄 UPDATE → $path");

    await _database.ref(path).update(reservation.toJson());
  }

  // ============================================================
  // ❌ DELETE
  // ============================================================

  @override
  Future<void> deleteReservation(ReservationModel reservation) async {
    final path = _buildPath(reservation);

    debugPrint("❌ DELETE → $path");

    await _database.ref(path).remove();
  }

  // ============================================================
  // 🔧 HELPERS
  // ============================================================

  String _buildPath(ReservationModel reservation) {
    final normalizedDate = _normalizeDate(reservation.appointmentDateTime);

    return "doctors/${reservation.doctorKey}"
        "/reservations/$normalizedDate"
        "/${reservation.key}";
  }

  String _normalizeDate(String? date) {
    if (date == null || date.isEmpty) {
      return DateFormat("dd-MM-yyyy").format(DateTime.now());
    }

    try {
      if (date.contains("/")) {
        final parsed = DateFormat("dd/MM/yyyy").parse(date);
        return DateFormat("dd-MM-yyyy").format(parsed);
      }

      if (date.contains("-")) {
        return date;
      }

      return date;
    } catch (_) {
      return date.replaceAll("/", "-");
    }
  }

  ReservationModel? _mapSnapshot(DataSnapshot snapshot) {
    final data = snapshot.value;

    if (data == null || data is! Map) return null;

    final json = Map<String, dynamic>.from(data);

    // 🛑 Ignore date nodes (they contain reservations not fields)
    if (!json.containsKey('doctor_key')) {
      return null;
    }

    json['key'] ??= snapshot.key;

    return ReservationModel.fromJson(json);
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
    _currentRef = null;

    debugPrint("🛑 Reservation listener stopped");
  }
}
