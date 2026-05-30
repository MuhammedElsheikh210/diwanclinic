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
  Timer? _reconnectTimer;

  // ============================================================
  // 🔥 REALTIME LISTENING
  // ============================================================

  Future<void> startListening() async {
    if (_isListening) {
      AppLogger.warning("NOTIFICATION", "Already listening → skip");
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    await useCase.startListening();

    void onStreamError(Object error, StackTrace stack) {
      AppLogger.error("NOTIFICATION_SERVICE", "Stream error — scheduling reconnect", error, stack);
      _scheduleReconnect();
    }

    _addedSub = useCase.onAdded.listen(
      (model) => onNotificationAdded?.call(model),
      onError: onStreamError,
      cancelOnError: false,
    );

    _changedSub = useCase.onChanged.listen(
      (model) => onNotificationUpdated?.call(model),
      onError: onStreamError,
      cancelOnError: false,
    );

    _removedSub = useCase.onRemoved.listen(
      (key) => onNotificationRemoved?.call(key),
      onError: onStreamError,
      cancelOnError: false,
    );

    _isListening = true;
    AppLogger.success("NOTIFICATION", "Listening started ✅");
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () async {
      AppLogger.info("NOTIFICATION_SERVICE", "Reconnecting realtime...");
      _isListening = false;
      await startListening();
    });
  }


  Future<void> getAllNotificationsOnlineData({
    required Function(List<NotificationModel>) voidCallBack,
  }) async {
    final result = await useCase.fetchAllNotifications();

    result.fold(
          (l) => Loader.showError("Network error while loading notifications"),
          (r) => voidCallBack(r),
    );
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
  // 🛑 STOP LISTENING
  // ============================================================

  Future<void> stopListening() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    _isListening = false;

    // Capture before nulling to avoid cancelling newly-created subscriptions
    // if startListening() races with this call
    final addedSub = _addedSub;
    final changedSub = _changedSub;
    final removedSub = _removedSub;

    _addedSub = null;
    _changedSub = null;
    _removedSub = null;

    await addedSub?.cancel();
    await changedSub?.cancel();
    await removedSub?.cancel();

    await useCase.stopListening();

    AppLogger.warning("NOTIFICATION", "Stopped listening 🛑");
  }

  // ============================================================
  // 🛑 DISPOSE (full cleanup — controllers closed)
  // ============================================================

  Future<void> dispose() async {
    await stopListening();
    await useCase.dispose();
    AppLogger.warning("NOTIFICATION", "Service disposed 🛑");
  }
}