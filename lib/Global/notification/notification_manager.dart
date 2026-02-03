import '../../../../../index/index_main.dart';

/// Central manager to handle all notification sending logic
class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();

  factory NotificationManager() => _instance;

  late final NotificationSendRepository _repo;
  late final FirebaseMessaging _messaging;

  String? _deviceToken;

  NotificationManager._internal() {
    _messaging = FirebaseMessaging.instance;

    final fcmService = FcmSenderService(
      projectId: 'pos-app-c2ced',
      serviceAccountPath: 'assets/config/${Strings.file_name}.json',
    );

    _repo = NotificationSendRepository(fcmService);
  }

  /// Initialize and request permissions once (e.g., in app startup)
  Future<void> init() async {
    await _messaging.requestPermission();
    _deviceToken = await _messaging.getToken();
  }

  // ---------------------------------------------------------------------------
  // 🔹 Topic Management
  // ---------------------------------------------------------------------------

  /// Subscribe the current device to a specific topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
    } catch (e) {
    }
  }

  /// Unsubscribe the current device from a specific topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
    } catch (e) {
    }
  }

  /// Check if the current device has a valid token (for safety)
  bool get hasToken => _deviceToken != null && _deviceToken!.isNotEmpty;

  // ---------------------------------------------------------------------------
  // 🔹 Sending Messages
  // ---------------------------------------------------------------------------

  /// Send to a specific device (by FCM token)
  Future<String> sendToDevice({
    required String title,
    required String body,
    String? token,
    Map<String, dynamic>? data,
  }) async {
    final targetToken = token ?? _deviceToken;

    if (targetToken == null) {
      return '❌ Device token not available';
    }

    return _repo.sendTokenNotification(
      token: targetToken,
      title: title,
      body: body,
      data: data ?? {},
    );
  }

  /// Send to multiple devices (multicast)
  Future<String> sendToMultipleDevices({
    required List<String> tokens,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    if (tokens.isEmpty) {
      return '⚠️ No tokens provided to sendToMultipleDevices()';
    }

    return _repo.sendMultipleTokensNotification(
      tokens: tokens,
      title: title,
      body: body,
      data: data ?? {},
    );
  }

  /// Send to a topic
  Future<String> sendToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    bool autoSubscribe = false,
  }) async {
    // Optionally auto-subscribe before sending
    if (autoSubscribe) {
      await subscribeToTopic(topic);
    }

    return _repo.sendTopicNotification(
      topic: topic,
      title: title,
      body: body,
      data: data ?? {},
    );
  }
}
