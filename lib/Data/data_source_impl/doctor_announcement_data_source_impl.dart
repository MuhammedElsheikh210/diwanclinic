import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../../index/index_main.dart';

class DoctorAnnouncementDataSourceImpl implements DoctorAnnouncementDataSource {
  final FirebaseDatabase _database;
  final ClientSourceRepo _clientSourceRepo;

  DoctorAnnouncementDataSourceImpl(this._database, this._clientSourceRepo);

  DatabaseReference? _rootRef;
  final List<StreamSubscription> _subscriptions = [];

  final _addedController =
      StreamController<DoctorAnnouncementModel>.broadcast();
  final _changedController =
      StreamController<DoctorAnnouncementModel>.broadcast();
  final _removedController = StreamController<String>.broadcast();

  @override
  Stream<DoctorAnnouncementModel> get onAdded => _addedController.stream;

  @override
  Stream<DoctorAnnouncementModel> get onChanged => _changedController.stream;

  @override
  Stream<String> get onRemoved => _removedController.stream;

  // ============================================================
  // 🎧 START LISTENING
  // path: doctors/{doctorKey}/doctor_announcements/{date}/
  // ============================================================

  @override
  Future<void> startListening({
    required String doctorKey,
    required String date,
  }) async {
    if (_rootRef != null) {
      AppLogger.warning("ANNOUNCEMENT", "Already listening → skip");
      return;
    }

    _rootRef = _database.ref(
      "doctors/$doctorKey/doctor_announcements/$date",
    );

    AppLogger.info(
      "ANNOUNCEMENT",
      "Start listening → doctors/$doctorKey/doctor_announcements/$date",
    );

    final addedSub = _rootRef!.onChildAdded.listen((event) {
      final model = _parse(event.snapshot);
      if (model != null && !_addedController.isClosed) {
        _addedController.add(model);
      }
    });

    final changedSub = _rootRef!.onChildChanged.listen((event) {
      final model = _parse(event.snapshot);
      if (model != null && !_changedController.isClosed) {
        _changedController.add(model);
      }
    });

    final removedSub = _rootRef!.onChildRemoved.listen((event) {
      final key = event.snapshot.key;
      if (key != null && !_removedController.isClosed) {
        _removedController.add(key);
      }
    });

    _subscriptions.addAll([addedSub, changedSub, removedSub]);
  }

  // ============================================================
  // ➕ CREATE
  // ============================================================

  @override
  Future<void> createAnnouncement(DoctorAnnouncementModel model) async {
    final path =
        "doctors/${model.doctorKey}/doctor_announcements/${model.date}/${model.key}.json";

    await _clientSourceRepo.request(
      HttpMethod.PATCH,
      "/$path",
      params: model.toJson(),
    );
  }

  // ============================================================
  // 🔕 DEACTIVATE PREVIOUS (mark old announcements as inactive)
  // ============================================================

  @override
  Future<void> deactivatePreviousAnnouncements({
    required String doctorKey,
    required String date,
  }) async {
    try {
      final snapshot = await _database
          .ref("doctors/$doctorKey/doctor_announcements/$date")
          .get();

      if (!snapshot.exists || snapshot.value == null) return;

      final data = Map<String, dynamic>.from(snapshot.value as Map);

      for (final entry in data.entries) {
        final key = entry.key;
        await _clientSourceRepo.request(
          HttpMethod.PATCH,
          "/doctors/$doctorKey/doctor_announcements/$date/$key.json",
          params: {"is_active": false},
        );
      }
    } catch (e) {
      AppLogger.error("ANNOUNCEMENT", "deactivatePrevious error", e);
    }
  }

  // ============================================================
  // 🔍 FETCH LATEST
  // ============================================================

  @override
  Future<DoctorAnnouncementModel?> fetchLatestAnnouncement({
    required String doctorKey,
    required String date,
  }) async {
    try {
      final snapshot = await _database
          .ref("doctors/$doctorKey/doctor_announcements/$date")
          .get();

      if (!snapshot.exists || snapshot.value == null) return null;

      final data = Map<String, dynamic>.from(snapshot.value as Map);

      final list = <DoctorAnnouncementModel>[];

      data.forEach((key, value) {
        if (value is Map) {
          final json = Map<String, dynamic>.from(
            value.map((k, v) => MapEntry(k.toString(), v)),
          );
          json['key'] = key;
          list.add(DoctorAnnouncementModel.fromJson(json));
        }
      });

      if (list.isEmpty) return null;

      list.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));

      final active = list.firstWhere(
        (a) => a.isActive == true,
        orElse: () => list.first,
      );

      return active;
    } catch (e) {
      AppLogger.error("ANNOUNCEMENT", "fetchLatest error", e);
      return null;
    }
  }

  // ============================================================
  // 🧠 PARSE
  // ============================================================

  DoctorAnnouncementModel? _parse(DataSnapshot snapshot) {
    final data = snapshot.value;
    if (data == null || data is! Map) return null;

    try {
      final json = Map<String, dynamic>.from(
        data.map((k, v) => MapEntry(k.toString(), v)),
      );
      json['key'] = snapshot.key;
      return DoctorAnnouncementModel.fromJson(json);
    } catch (e) {
      AppLogger.error("ANNOUNCEMENT", "Parse error", e);
      return null;
    }
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
    _rootRef = null;
    AppLogger.warning("ANNOUNCEMENT", "Stopped listening");
  }
}
