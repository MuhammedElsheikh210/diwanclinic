import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../../index/index_main.dart';

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final FirebaseDatabase _database;
  final ClientSourceRepo _clientSourceRepo;

  NotificationRemoteDataSourceImpl(this._database, this._clientSourceRepo);

  DatabaseReference? _rootRef;
  final List<StreamSubscription> _subscriptions = [];

  // ============================================================
  // 🌊 STREAM CONTROLLERS
  // ============================================================

  final _addedController = StreamController<NotificationModel>.broadcast();
  final _changedController = StreamController<NotificationModel>.broadcast();
  final _removedController = StreamController<String>.broadcast();

  @override
  Stream<NotificationModel> get onAdded => _addedController.stream;

  @override
  Stream<NotificationModel> get onChanged => _changedController.stream;

  @override
  Stream<String> get onRemoved => _removedController.stream;

  // ============================================================
  // 🎧 START LISTENING
  // ============================================================

  @override
  Future<void> startListening() async {
    await stopListening();

    final uid = LocalUser().getUserData().uid ?? "";

    if (uid.isEmpty) {
      print("❌ No UID found, can't listen to notifications");
      return;
    }

    final query = _database
        .ref("notifications")
        .orderByChild("to_key")
        .equalTo(uid);

    print("🎧 Listening on notifications where to_key = $uid");

    // 🟢 ADDED
    final addedSub = query.onChildAdded.listen((event) {
      final model = _parseNotification(event.snapshot);
      if (model != null) {
        print("🔔 Notification Added → ${model.key}");
        _addedController.add(model);
      }
    });

    // 🔄 UPDATED
    final changedSub = query.onChildChanged.listen((event) {
      final model = _parseNotification(event.snapshot);
      if (model != null) {
        print("🔄 Notification Updated → ${model.key}");
        _changedController.add(model);
      }
    });

    // ❌ REMOVED (يفضل يفضل على الروت)
    final removedSub = _database.ref("notifications").onChildRemoved.listen((
      event,
    ) {
      final key = event.snapshot.key;
      if (key != null) {
        print("❌ Notification Removed → $key");
        _removedController.add(key);
      }
    });

    _subscriptions.addAll([addedSub, changedSub, removedSub]);
  }

  // ============================================================
  // 🌐 FETCH NOTIFICATIONS (ONLINE READ)
  // ============================================================

  @override
  Future<List<NotificationModel>> fetchNotifications(
    Map<String, dynamic> filters,
  ) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        "/${ApiConstatns.notifications}.json",
        params: filters,
      );

      if (response == null || response is! Map) {
        print("⚠️ No notifications found");
        return [];
      }

      final List<NotificationModel> list = [];

      response.forEach((key, value) {
        if (value is Map) {
          final json = Map<String, dynamic>.from(
            value.map((k, v) => MapEntry(k.toString(), v)),
          );
          json['key'] = key;
          list.add(NotificationModel.fromJson(json));
        }
      });

      print("☁️ Notifications fetched → ${list.length}");
      return list;
    } catch (e) {
      print("🔥 Fetch Notifications Error → $e");
      return [];
    }
  }

  // ============================================================
  // 🧠 PARSE NOTIFICATION
  // ============================================================

  NotificationModel? _parseNotification(DataSnapshot snapshot) {
    final data = snapshot.value;

    if (data == null || data is! Map) return null;

    try {
      final json = Map<String, dynamic>.from(
        data.map((k, v) => MapEntry(k.toString(), v)),
      );

      json['key'] = snapshot.key;

      return NotificationModel.fromJson(json);
    } catch (e) {
      print("🔥 Notification parse error → $e");
      return null;
    }
  }

  // ============================================================
  // ☁️ CREATE NOTIFICATION
  // ============================================================

  @override
  Future<void> createNotification(NotificationModel model) async {
    final key = model.key;
    print("☁️ Create Notification → $key");

    await _clientSourceRepo.request(
      HttpMethod.PATCH,
      "/${ApiConstatns.notifications}/$key.json",
      params: model.toJson(),
    );
  }

  // ============================================================
  // 🔄 UPDATE NOTIFICATION
  // ============================================================

  @override
  Future<void> updateNotification(NotificationModel model) async {
    final key = model.key;
    print("☁️ Update Notification → $key");

    await _clientSourceRepo.request(
      HttpMethod.PATCH,
      "/${ApiConstatns.notifications}/$key.json",
      params: model.toJson(),
    );
  }

  // ============================================================
  // ❌ DELETE NOTIFICATION
  // ============================================================

  @override
  Future<void> deleteNotification(String key) async {
    print("☁️ Delete Notification → $key");

    await _clientSourceRepo.request(
      HttpMethod.DELETE,
      "/${ApiConstatns.notifications}/$key.json",
      params: {},
    );
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

    print("🛑 Notification listeners stopped");
  }
}
