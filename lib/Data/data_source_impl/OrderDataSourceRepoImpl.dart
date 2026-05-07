import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

import '../../index/index_main.dart';

class OrderDataSourceRepoImpl extends OrderDataSourceRepo {
  final ClientSourceRepo _clientSourceRepo;

  /// ✅ نفس فكرة notifications بالظبط
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  OrderDataSourceRepoImpl(this._clientSourceRepo);

  // ============================================================
  // 🔥 REALTIME
  // ============================================================

  DatabaseReference? _rootRef;

  final List<StreamSubscription> _subscriptions = [];

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
  // 🎧 START LISTENING
  // ============================================================

  @override
  Future<void> startListening() async {
    try {
      /// ✅ منع التكرار
      if (_rootRef != null) {
        AppLogger.warning("ORDER", "Already listening → skip");

        return;
      }

      final sessionUser = Get.find<UserSession>().user?.user;

      final uid = sessionUser?.uid;

      if (uid == null || uid.isEmpty) {
        AppLogger.warning("ORDER", "UID is null → skip listening");

        return;
      }

      _rootRef = _database.ref(ApiConstatns.orders);
      AppLogger.info("ORDER", "Start listening → ${ApiConstatns.orders}");

      // ============================================================
      // 🟢 ADDED
      // ============================================================

      final addedSub = _rootRef!.onChildAdded.listen((event) {
        AppLogger.debug("ORDER", "🔥 onChildAdded → ${event.snapshot.key}");

        final model = _parseOrder(event.snapshot);

        if (model != null) {
          if (!_addedController.isClosed) {
            _addedController.add(model);
          }

          AppLogger.success("ORDER", "Order added → ${model.key}");
        }
      });

      // ============================================================
      // 🔄 CHANGED
      // ============================================================

      final changedSub = _rootRef!.onChildChanged.listen((event) {
        AppLogger.debug("ORDER", "🔄 onChildChanged → ${event.snapshot.key}");

        final model = _parseOrder(event.snapshot);

        if (model != null) {
          if (!_changedController.isClosed) {
            _changedController.add(model);
          }
        }
      });

      // ============================================================
      // ❌ REMOVED
      // ============================================================

      final removedSub = _rootRef!.onChildRemoved.listen((event) {
        final key = event.snapshot.key;

        AppLogger.warning("ORDER", "❌ Removed → $key");

        if (key != null && !_removedController.isClosed) {
          _removedController.add(key);
        }
      });

      _subscriptions.addAll([addedSub, changedSub, removedSub]);
    } catch (e, stack) {
      AppLogger.error("ORDER", "startListening error", e, stack);
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

    AppLogger.warning("ORDER", "Stopped listening");
  }

  // ============================================================
  // 🧠 PARSE
  // ============================================================

  OrderModel? _parseOrder(DataSnapshot snapshot) {
    final data = snapshot.value;

    if (data == null || data is! Map) {
      AppLogger.warning("ORDER", "Invalid snapshot data");

      return null;
    }

    try {
      final json = Map<String, dynamic>.from(
        data.map((k, v) => MapEntry(k.toString(), v)),
      );

      json['key'] = snapshot.key;

      return OrderModel.fromJson(json);
    } catch (e, stack) {
      AppLogger.error("ORDER", "Parse error", e, stack);

      return null;
    }
  }

  // ============================================================
  // 🌐 FETCH ALL
  // ============================================================

  @override
  Future<List<OrderModel>> fetchAllOrders() async {
    try {
      final sessionUser = Get.find<UserSession>().user?.user;

      final uid = sessionUser?.uid;

      if (uid == null || uid.isEmpty) {
        AppLogger.warning("ORDER", "UID null → fetch skip");

        return [];
      }

      final snapshot = await _database.ref("${ApiConstatns.orders}/$uid").get();

      if (!snapshot.exists || snapshot.value == null) {
        return [];
      }

      final data = Map<String, dynamic>.from(snapshot.value as Map);

      final List<OrderModel> list = [];

      data.forEach((key, value) {
        if (value is Map) {
          final json = Map<String, dynamic>.from(
            value.map((k, v) => MapEntry(k.toString(), v)),
          );

          json['key'] = key;

          list.add(OrderModel.fromJson(json));
        }
      });

      list.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));

      AppLogger.success("ORDER", "Fetched all orders → ${list.length}");

      return list;
    } catch (e, stack) {
      AppLogger.error("ORDER", "fetchAllOrders error", e, stack);

      return [];
    }
  }

  // ============================================================
  // 📥 GET ORDERS
  // ============================================================

  @override
  Future<List<OrderModel?>> getOrders(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  ) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        "/${ApiConstatns.orders}.json",
        params: data,
      );

      List<OrderModel?> orderList = handleResponse<OrderModel>(
        response,
        (json) => OrderModel.fromJson(json),
      );

      return orderList;
    } catch (e) {
      return [];
    }
  }

  // ============================================================
  // ➕ ADD
  // ============================================================

  @override
  Future<SuccessModel> addOrder(Map<String, dynamic> data, String key) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.PATCH,
        "/${ApiConstatns.orders}/$key.json",
        params: data,
      );

      return SuccessModel.fromJson(response);
    } catch (e) {
      return SuccessModel(message: "فشل إضافة الطلب أونلاين");
    }
  }

  // ============================================================
  // 🔄 UPDATE
  // ============================================================

  @override
  Future<SuccessModel> updateOrder(
    Map<String, dynamic> data,
    String key,
  ) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.PATCH,
        "/${ApiConstatns.orders}/$key.json",
        params: data,
      );

      return SuccessModel.fromJson(response);
    } catch (e) {
      return SuccessModel(message: "فشل تحديث الطلب أونلاين");
    }
  }

  // ============================================================
  // ❌ DELETE
  // ============================================================

  @override
  Future<SuccessModel> deleteOrder(
    Map<String, dynamic> data,
    String key,
  ) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.DELETE,
        "/${ApiConstatns.orders}/$key.json",
        params: data,
      );

      return SuccessModel.fromJson(response ?? {"message": "تم الحذف بنجاح"});
    } catch (e) {
      return SuccessModel(message: "فشل حذف الطلب أونلاين");
    }
  }
}
