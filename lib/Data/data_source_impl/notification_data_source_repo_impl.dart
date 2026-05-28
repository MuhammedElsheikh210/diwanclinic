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
    // Always stop first to ensure clean state before re-subscribing
    await stopListening();

    final sessionUser = Get.find<UserSession>().user?.user;
    final uid = sessionUser?.uid;

    if (uid == null || uid.isEmpty) {
      AppLogger.warning("NOTIFICATION", "UID is null → skip listening");
      return;
    }

    _rootRef = _database.ref("notifications/$uid");
    AppLogger.info("NOTIFICATION", "Start listening → notifications/$uid");

    void onError(Object error, StackTrace stack) {
      AppLogger.error("NOTIFICATION", "Listener error on notifications/$uid", error, stack);
    }

    // 🟢 ADDED
    final addedSub = _rootRef!.onChildAdded.listen(
      (event) {
        AppLogger.debug("NOTIFICATION", "🔥 onChildAdded → ${event.snapshot.key}");
        final model = _parseNotification(event.snapshot);
        if (model != null) {
          if (!_addedController.isClosed) _addedController.add(model);
          AppLogger.success("NOTIFICATION", "Notification added → ${model.title}");
        } else {
          AppLogger.warning("NOTIFICATION", "Failed to parse notification");
        }
      },
      onError: onError,
      cancelOnError: false,
    );

    // 🔄 UPDATED
    final changedSub = _rootRef!.onChildChanged.listen(
      (event) {
        AppLogger.debug("NOTIFICATION", "🔄 onChildChanged → ${event.snapshot.key}");
        final model = _parseNotification(event.snapshot);
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
        AppLogger.warning("NOTIFICATION", "❌ Removed → $key");
        if (key != null && !_removedController.isClosed) {
          _removedController.add(key);
        }
      },
      onError: onError,
      cancelOnError: false,
    );

    _subscriptions.addAll([addedSub, changedSub, removedSub]);
    AppLogger.success("NOTIFICATION", "Realtime initialized ✅ → notifications/$uid");
  }

  // ============================================================
  // 🧠 PARSE
  // ============================================================

  NotificationModel? _parseNotification(DataSnapshot snapshot) {
    final data = snapshot.value;

    if (data == null || data is! Map) {
      AppLogger.warning("NOTIFICATION", "Invalid snapshot data");
      return null;
    }

    try {
      final json = Map<String, dynamic>.from(
        data.map((k, v) => MapEntry(k.toString(), v)),
      );

      json['key'] = snapshot.key;

      return NotificationModel.fromJson(json);
    } catch (e, stack) {
      AppLogger.error("NOTIFICATION", "Parse error", e, stack);
      return null;
    }
  }

  // ============================================================
  // 🌐 FETCH
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

      return list;
    } catch (e) {
      return [];
    }
  }

  // ============================================================
  // ☁️ CREATE
  // ============================================================

  @override
  Future<void> createNotification(NotificationModel model) async {
    final key = model.key;

    await _clientSourceRepo.request(
      HttpMethod.PATCH,
      "/${ApiConstatns.notifications}/$key.json",
      params: model.toJson(),
    );
  }

  // ============================================================
  // 🔄 UPDATE
  // ============================================================

  @override
  Future<void> updateNotification(NotificationModel model) async {
    final key = model.key;

    await _clientSourceRepo.request(
      HttpMethod.PATCH,
      "/${ApiConstatns.notifications}/$key.json",
      params: model.toJson(),
    );
  }

  // ============================================================
  // ❌ DELETE
  // ============================================================

  @override
  Future<void> deleteNotification(String key) async {
    await _clientSourceRepo.request(
      HttpMethod.DELETE,
      "/${ApiConstatns.notifications}/$key.json",
      params: {},
    );
  }


  @override
  Future<List<NotificationModel>> fetchAllNotifications() async {
    try {
      final sessionUser = Get.find<UserSession>().user?.user;
      final uid = sessionUser?.uid;

      if (uid == null || uid.isEmpty) {
        AppLogger.warning("NOTIFICATION", "UID is null → fetchAll skip");
        return [];
      }

      final snapshot = await _database.ref("notifications/$uid").get();

      if (!snapshot.exists || snapshot.value == null) {
        AppLogger.info("NOTIFICATION", "No notifications found");
        return [];
      }

      final data = Map<String, dynamic>.from(snapshot.value as Map);

      final List<NotificationModel> list = [];

      data.forEach((key, value) {
        if (value is Map) {
          final json = Map<String, dynamic>.from(
            value.map((k, v) => MapEntry(k.toString(), v)),
          );

          json['key'] = key;

          final model = NotificationModel.fromJson(json);
          list.add(model);
        }
      });

      /// 🔥 ترتيب الأحدث أولاً
      list.sort((a, b) => (b.createAt ?? 0).compareTo(a.createAt ?? 0));

      AppLogger.success(
        "NOTIFICATION",
        "Fetched all notifications → ${list.length}",
      );

      return list;
    } catch (e, stack) {
      AppLogger.error("NOTIFICATION", "fetchAll error", e, stack);
      return [];
    }
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

    AppLogger.warning("NOTIFICATION", "Stopped listening");
  }
}