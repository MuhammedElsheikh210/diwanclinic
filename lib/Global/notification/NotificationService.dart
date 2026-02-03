import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../index/index_main.dart';

/// 🔔 Background message handler — must be top-level
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("🔔 [Background] MessageId: ${message.messageId}");
  log("🧩 [Background Data]: ${message.data}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _currentTopic;

  // ─────────────────────────────────────────────
  // 🚀 CORE INIT (call in main)
  // ─────────────────────────────────────────────
  Future<void> initCore() async {
    log("🚀 Initializing Notification Core...");

    await _requestPermission();
    await _setupLocalNotifications();
    await _configureForegroundPresentation();
    await _setupMessageListeners();

    log("✅ Notification core ready");
  }

  // ─────────────────────────────────────────────
  // 🔔 ROLE-BASED SUBSCRIBE (call AFTER login)
  // ─────────────────────────────────────────────
  Future<void> subscribeAfterLogin() async {
    final topic = _topicFromUserRole();

    if (topic.isEmpty) {
      log("⚠️ No role found → skip subscribe");
      return;
    }

    await _messaging.subscribeToTopic(topic);
    _currentTopic = topic;

    log("✅ Subscribed to topic: $topic");
  }

  // 🔄 Logout / role switch
  Future<void> unsubscribeAllRoles() async {
    for (final role in UserType.values) {
      final topic = "role_${role.name}";
      await _messaging.unsubscribeFromTopic(topic);
      log("🚫 Unsubscribed from topic: $topic");
    }
    _currentTopic = null;
  }

  void printCurrentTopic() {
    log("📌 Current topic: ${_currentTopic ?? 'NONE'}");
  }

  // ─────────────────────────────────────────────
  // 🔐 Permissions
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
  // 📲 Foreground (iOS)
  // ─────────────────────────────────────────────
  Future<void> _configureForegroundPresentation() async {
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // ─────────────────────────────────────────────
  // 🔔 Local Notifications
  // ─────────────────────────────────────────────
  Future<void> _setupLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    const settings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          _handlePayload(details.payload!);
        }
      },
    );

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
  // 🎧 FCM listeners
  // ─────────────────────────────────────────────
  Future<void> _setupMessageListeners() async {
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNavigation(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleNavigation);

    FirebaseMessaging.onMessage.listen((message) {
      _showLocalNotification(message);
    });
  }

  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────
  String _topicFromUserRole() {
    final role = LocalUser().getUserData().userType?.name;
    return role == null ? "" : "role_$role";
  }

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
      payload: message.data['target'],
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

  void _handlePayload(String payload) {
    log("🧩 Payload: $payload");
  }
}
