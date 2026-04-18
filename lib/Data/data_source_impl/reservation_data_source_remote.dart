import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../../index/index_main.dart';

class ReservationRemoteDataSourceImpl implements ReservationRemoteDataSource {
  final FirebaseDatabase _database;

  ReservationRemoteDataSourceImpl(this._database);

  DatabaseReference? _rootRef;
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

  @override
  Future<void> startListening({required String doctorKey}) async {
    await stopListening();

    final path = "doctors/$doctorKey/reservations";
    _rootRef = _database.ref(path);


    final dateSub = _rootRef!.onChildAdded.listen((dateEvent) {
      final dateKey = dateEvent.snapshot.key;
      if (dateKey == null) return;


      // ✅ Build correct reference manually
      final dateRef = _rootRef!.child(dateKey);

      _listenInsideDate(dateRef);
    });

    _subscriptions.add(dateSub);
  }

  void _listenInsideDate(DatabaseReference dateRef) {

    // ➕ Reservation Added
    final addedSub = dateRef.onChildAdded.listen((event) {
      final key = event.snapshot.key;
      if (key == null) return;


      final model = _parseReservation(event.snapshot);
      if (model != null) _addedController.add(model);
    });

    // 🔄 Reservation Updated
    final changedSub = dateRef.onChildChanged.listen((event) {
      final key = event.snapshot.key;
      if (key == null) return;


      final model = _parseReservation(event.snapshot);
      if (model != null) _changedController.add(model);
    });

    // ❌ Reservation Removed
    final removedSub = dateRef.onChildRemoved.listen((event) {
      final key = event.snapshot.key;
      if (key == null) return;

      _removedController.add(key);
    });

    _subscriptions.addAll([addedSub, changedSub, removedSub]);
  }

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
      return null;
    }
  }

  @override
  Future<void> createReservation(ReservationModel reservation) async {
    final path = _buildPath(reservation);
    await _database.ref(path).set(reservation.toJson());
  }

  @override
  Future<void> updateReservation(ReservationModel reservation) async {
    final path = _buildPath(reservation);
    await _database.ref(path).update(reservation.toJson());
  }

  @override
  Future<void> deleteReservation(ReservationModel reservation) async {
    final path = _buildPath(reservation);
    await _database.ref(path).remove();
  }

  String _buildPath(ReservationModel reservation) {
    final normalizedDate = AppDateFormatter.toDash(
      reservation.appointmentDateTime,
    );

    return "doctors/${reservation.doctorUid}"
        "/reservations/$normalizedDate"
        "/${reservation.key}";
  }

  @override
  Future<void> stopListening() async {
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();
    _rootRef = null;

  }

  @override
  Future<List<ReservationModel>> fetchReservationsOnce({
    required String doctorKey,
    required String date, // yyyy-MM-dd
  }) async {
    try {
      final ref = _database.ref("doctors/$doctorKey/reservations/$date");


      final snapshot = await ref.get();

      // ❗ مفيش داتا
      if (!snapshot.exists || snapshot.value == null) {
        return [];
      }

      final data = snapshot.value;

      if (data is! Map) {
        return [];
      }

      final List<ReservationModel> list = [];

      data.forEach((key, value) {
        try {
          if (value == null || value is! Map) return;

          final json = Map<String, dynamic>.from(
            value.map((k, v) => MapEntry(k.toString(), v)),
          );

          json['key'] = key;

          final model = ReservationModel.fromJson(json);

          list.add(model);
        } catch (e) {
        }
      });


      return list;
    } catch (e) {
      return [];
    }
  }
}
