import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../../index/index_main.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log("🔔 [Background] MessageId: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? _currentTopic;
  String? _pendingTopic;
  bool _initialized = false;

  String? get token => _fcmToken;

  // ─────────────────────────────────────────────
  // 🚀 INIT
  // ─────────────────────────────────────────────
  Future<void> initCore() async {
    if (_initialized) return;

    log("🚀 Initializing Notification Core...");

    await _requestPermission();
    await _setupLocalNotifications();
    await _configureForegroundPresentation();
    await _initTokenListener();

    _setupMessageListeners();

    _initialized = true;

    log("✅ Notification core ready");
  }

  // ─────────────────────────────────────────────
  // 🔐 PERMISSION
  // ─────────────────────────────────────────────
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    log("🔔 Permission: ${settings.authorizationStatus}");
  }

  // ─────────────────────────────────────────────
  // 📲 TOKEN SAFE
  // ─────────────────────────────────────────────
  Future<void> _initTokenListener() async {
    _messaging.onTokenRefresh.listen((newToken) async {
      log("🔥 TOKEN READY/REFRESHED: $newToken");
      _fcmToken = newToken;

      // لو كان في subscribe pending
      if (_pendingTopic != null) {
        await _subscribe(_pendingTopic!);
        _pendingTopic = null;
      }
    });

    try {
      final token = await _messaging.getToken();
      _fcmToken = token;
      log("🔥 FCM TOKEN: $token");
    } catch (_) {
      log("⚠️ Token not ready yet (Debug timing)");
    }
  }

  // ─────────────────────────────────────────────
  // 📲 FOREGROUND CONFIG
  // ─────────────────────────────────────────────
  Future<void> _configureForegroundPresentation() async {
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // ─────────────────────────────────────────────
  // 🔔 LOCAL NOTIFICATIONS
  // ─────────────────────────────────────────────
  Future<void> _setupLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    const settings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _localNotifications.initialize(settings);

    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  // ─────────────────────────────────────────────
  // 🎧 LISTENERS
  // ─────────────────────────────────────────────
  void _setupMessageListeners() {
    _messaging.getInitialMessage().then((message) {
      if (message != null) {
        _handleNavigation(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen(_handleNavigation);

    FirebaseMessaging.onMessage.listen((message) {
      _showLocalNotification(message);
    });
  }

  // ─────────────────────────────────────────────
  // 🔔 SUBSCRIBE SAFE
  // ─────────────────────────────────────────────
  Future<void> subscribeAfterLogin() async {
    final role = LocalUser().getUserData().userType?.name;
    if (role == null) return;

    final topic = "role_$role";

    if (_currentTopic == topic) return;

    // لو التوكن مش جاهز → خليه pending
    if (_fcmToken == null) {
      log("⏳ Token not ready → delaying subscription...");
      _pendingTopic = topic;
      return;
    }

    await _subscribe(topic);
  }

  Future<void> _subscribe(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      _currentTopic = topic;
      log("✅ Subscribed to $topic");
    } catch (e) {
      log("⚠️ Subscribe failed: $e");
    }
  }

  // ─────────────────────────────────────────────
  // 🔔 LOCAL SHOW
  // ─────────────────────────────────────────────
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        priority: Priority.high,
        importance: Importance.max,
      ),
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      notification.title,
      notification.body,
      details,
    );
  }

  void _handleNavigation(RemoteMessage message) {
    final target = message.data['target'];
    final id = message.data['id'];

    if (target == null) return;

    switch (target) {
      case "chat":
        Get.toNamed('/chat', arguments: id);
        break;
      case "reservation":
        Get.toNamed('/reservationDetails', arguments: id);
        break;
      case "offers":
        Get.toNamed('/offers');
        break;
    }
  }
}
