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
  // 🎧 START LISTENING (single date node — no subscription explosion)
  // ============================================================

  @override
  Future<void> startListening({
    required String doctorKey,
    required String date,
  }) async {
    await stopListening();

    final path = "doctors/$doctorKey/reservations/$date";
    AppLogger.info("RESERVATION_RT", "🎧 Start listening → $path");

    _rootRef = _database.ref(path);

    void onError(Object error, StackTrace stack) {
      AppLogger.error("RESERVATION_RT", "Listener error on $path", error, stack);
    }

    // ➕ ADDED
    final addedSub = _rootRef!.onChildAdded.listen(
      (event) {
        final key = event.snapshot.key;
        AppLogger.debug("RESERVATION_RT", "➕ Reservation Added → $key");
        if (key == null) return;
        final model = _parseReservation(event.snapshot);
        if (model != null) {
          AppLogger.success("RESERVATION_RT", "Reservation parsed → ${model.patientName}");
          if (!_addedController.isClosed) _addedController.add(model);
        } else {
          AppLogger.warning("RESERVATION_RT", "Failed to parse reservation → $key");
        }
      },
      onError: onError,
      cancelOnError: false,
    );

    // 🔄 CHANGED
    final changedSub = _rootRef!.onChildChanged.listen(
      (event) {
        final key = event.snapshot.key;
        AppLogger.debug("RESERVATION_RT", "🔄 Reservation Changed → $key");
        if (key == null) return;
        final model = _parseReservation(event.snapshot);
        if (model != null && !_changedController.isClosed) {
          _changedController.add(model);
        }
      },
      onError: onError,
      cancelOnError: false,
    );

    // ❌ REMOVED
    final removedSub = _rootRef!.onChildRemoved.listen(
      (event) {
        final key = event.snapshot.key;
        AppLogger.warning("RESERVATION_RT", "❌ Reservation Removed → $key");
        if (key != null && !_removedController.isClosed) {
          _removedController.add(key);
        }
      },
      onError: onError,
      cancelOnError: false,
    );

    _subscriptions.addAll([addedSub, changedSub, removedSub]);
    AppLogger.success("RESERVATION_RT", "Realtime initialized ✅ → $path");
  }

  // ============================================================
  // 🧠 PARSE
  // ============================================================

  ReservationModel? _parseReservation(DataSnapshot snapshot) {
    final data = snapshot.value;

    if (data == null || data is! Map) {
      AppLogger.warning("RESERVATION_RT", "Invalid snapshot data");

      return null;
    }

    try {
      final json = Map<String, dynamic>.from(
        data.map((k, v) => MapEntry(k.toString(), v)),
      );

      json['key'] = snapshot.key;

      return ReservationModel.fromJson(json);
    } catch (e, stack) {
      AppLogger.error("RESERVATION_RT", "Parse error", e, stack);

      return null;
    }
  }

  // ============================================================
  // ☁️ CREATE
  // ============================================================

  @override
  Future<void> createReservation(ReservationModel reservation) async {
    final path = _buildPath(reservation);

    AppLogger.info("RESERVATION_RT", "CREATE → $path");

    await _database.ref(path).set(reservation.toFirebaseJson());
  }

  // ============================================================
  // 🔄 UPDATE
  // ============================================================

  @override
  Future<void> updateReservation(ReservationModel reservation) async {
    final path = _buildPath(reservation);

    AppLogger.info("RESERVATION_RT", "UPDATE → $path");

    await _database.ref(path).update(reservation.toFirebaseJson());
  }

  // ============================================================
  // ❌ DELETE
  // ============================================================

  @override
  Future<void> deleteReservation(ReservationModel reservation) async {
    final path = _buildPath(reservation);

    AppLogger.warning("RESERVATION_RT", "DELETE → $path");

    await _database.ref(path).remove();
  }

  // ============================================================
  // 🔗 BUILD PATH
  // ============================================================

  String _buildPath(ReservationModel reservation) {
    final normalizedDate = AppDateFormatter.toDash(
      reservation.appointmentDateTime,
    );

    return "doctors/${reservation.doctorUid}"
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

    AppLogger.warning("RESERVATION_RT", "Stopped listening");
  }

  // ============================================================
  // 📥 FETCH ONCE
  // ============================================================

  @override
  Future<List<ReservationModel>> fetchReservationsOnce({
    required String doctorKey,
    required String date,
  }) async {
    try {
      final path = "doctors/$doctorKey/reservations/$date";

      AppLogger.info("RESERVATION_RT", "📥 Fetch once → $path");

      final ref = _database.ref(path);

      final snapshot = await ref.get();

      if (!snapshot.exists || snapshot.value == null) {
        AppLogger.warning("RESERVATION_RT", "No reservations found");

        return [];
      }

      final data = snapshot.value;

      if (data is! Map) {
        AppLogger.warning("RESERVATION_RT", "Snapshot is not Map");

        return [];
      }

      Map<String, dynamic> finalMap = {};

      // 🔥 FIX nested structure

      if (data.containsKey(date)) {
        AppLogger.debug("RESERVATION_RT", "Nested date structure detected");

        final inner = data[date];

        if (inner is Map) {
          finalMap = Map<String, dynamic>.from(
            inner.map((k, v) => MapEntry(k.toString(), v)),
          );
        } else {
          AppLogger.warning("RESERVATION_RT", "Inner date is not Map");

          return [];
        }
      } else {
        finalMap = Map<String, dynamic>.from(
          data.map((k, v) => MapEntry(k.toString(), v)),
        );
      }

      final List<ReservationModel> list = [];

      finalMap.forEach((key, value) {
        try {
          if (value == null) {
            return;
          }

          if (value is! Map) {
            return;
          }

          final json = Map<String, dynamic>.from(
            value.map((k, v) => MapEntry(k.toString(), v)),
          );

          json['key'] = key;

          final model = ReservationModel.fromJson(json);

          list.add(model);
        } catch (e, stack) {
          AppLogger.error("RESERVATION_RT", "Fetch parse error", e, stack);
        }
      });

      AppLogger.success(
        "RESERVATION_RT",
        "Fetched reservations → ${list.length}",
      );

      return list;
    } catch (e, stack) {
      AppLogger.error(
        "RESERVATION_RT",
        "fetchReservationsOnce error",
        e,
        stack,
      );

      return [];
    }
  }
}
