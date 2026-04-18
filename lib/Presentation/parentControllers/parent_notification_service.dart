import 'dart:async';

import '../../index/index_main.dart';

class NotificationPatentService {
  // ============================================================
  // 🧠 SINGLETON
  // ============================================================

  static final NotificationPatentService _instance =
  NotificationPatentService._internal();

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
  bool _isDisposed = false;

  // ============================================================
  // 🔥 REALTIME LISTENING
  // ============================================================

  Future<void> startListening() async {
    /// ✅ لو already listening → متعملش حاجة
    if (_isListening) {
      AppLogger.warning("NOTIFICATION", "Already listening → skip");
      return;
    }

    /// ❌ لو service اتقفلت → متبدأش تاني
    if (_isDisposed) {
      AppLogger.error("NOTIFICATION", "Service already disposed ❌");
      return;
    }

    await useCase.startListening();

    _addedSub = useCase.onAdded.listen((model) {
      if (_isDisposed) return;
      onNotificationAdded?.call(model);
    });

    _changedSub = useCase.onChanged.listen((model) {
      if (_isDisposed) return;
      onNotificationUpdated?.call(model);
    });

    _removedSub = useCase.onRemoved.listen((key) {
      if (_isDisposed) return;
      onNotificationRemoved?.call(key);
    });

    _isListening = true;

    AppLogger.success("NOTIFICATION", "Listening started ✅");
  }

  // ============================================================
  // ➕ ADD NOTIFICATION
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
  // 🌐 GET NOTIFICATIONS
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
    /// ✅ لو already disposed → متعملش حاجة
    if (_isDisposed) return;

    _isListening = false;
    _isDisposed = true;

    await _addedSub?.cancel();
    await _changedSub?.cancel();
    await _removedSub?.cancel();

    _addedSub = null;
    _changedSub = null;
    _removedSub = null;

    await useCase.dispose();

    AppLogger.warning("NOTIFICATION", "Service disposed 🛑");
  }
}