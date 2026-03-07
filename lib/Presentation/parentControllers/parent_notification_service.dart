// ignore_for_file: avoid_renaming_method_parameters

import 'dart:async';
import '../../index/index_main.dart';

class NotificationPatentService {
  // ============================================================
  // 🧠 SINGLETON
  // ============================================================

  static final NotificationPatentService _instance = NotificationPatentService._internal();

  factory NotificationPatentService() => _instance;

  NotificationPatentService._internal();

  final NotificationUseCases useCase = initController(
    () => NotificationUseCases(Get.find()),
  );

  // ============================================================
  // 🎧 REALTIME CALLBACKS
  // ============================================================

  Function(NotificationModel model)? onNotificationAdded;
  Function(NotificationModel model)? onNotificationUpdated;
  Function(String key)? onNotificationRemoved;

  StreamSubscription? _addedSub;
  StreamSubscription? _changedSub;
  StreamSubscription? _removedSub;

  bool _isListening = false;

  // ============================================================
  // 🔥 REALTIME LISTENING
  // ============================================================

  Future<void> startListening() async {
    if (_isListening) return;

    await useCase.startListening();

    _addedSub = useCase.onAdded.listen((model) {
      onNotificationAdded?.call(model);
    });

    _changedSub = useCase.onChanged.listen((model) {
      onNotificationUpdated?.call(model);
    });

    _removedSub = useCase.onRemoved.listen((key) {
      onNotificationRemoved?.call(key);
    });

    _isListening = true;
  }

  // ============================================================
  // ➕ ADD NOTIFICATION (OLD NAME KEPT STYLE)
  // ============================================================

  Future<void> addNotificationData({
    required NotificationModel notification,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    final result = await useCase.createNotification(notification);

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  // ============================================================
  // 🔄 UPDATE NOTIFICATION
  // ============================================================

  Future<void> updateNotificationData({
    required NotificationModel notification,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    final result = await useCase.updateNotification(notification);

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  // ============================================================
  // ❌ DELETE NOTIFICATION
  // ============================================================

  Future<void> deleteNotificationData({
    required String notificationKey,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    final result = await useCase.deleteNotification(notificationKey);

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  // ============================================================
  // 🌐 GET NOTIFICATIONS (ONLINE ONLY)
  // ============================================================

  Future<void> getNotificationsOnlineData({
    required FirebaseFilter firebaseFilter,
    required Function(List<NotificationModel>) voidCallBack,
  }) async {
    final result = await useCase.fetchNotifications(firebaseFilter.toJson());

    result.fold(
      (l) => Loader.showError("Network error while loading notifications"),
      (r) => voidCallBack(r),
    );
  }

  // ============================================================
  // 🛑 DISPOSE
  // ============================================================

  Future<void> dispose() async {
    _isListening = false;

    await _addedSub?.cancel();
    await _changedSub?.cancel();
    await _removedSub?.cancel();

    await useCase.dispose();
  }
}
