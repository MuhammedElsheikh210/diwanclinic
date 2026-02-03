import 'package:diwanclinic/Global/notification/fcm_sender.dart';

/// 🔹 Repository layer between UI and FcmSender
/// Acts as a single communication point between the UI/view-model
/// and the FCM sender service.
class NotificationSendRepository {
  final FcmSenderService fcmSender;

  NotificationSendRepository(this.fcmSender);

  /// 🔹 Send a notification to a specific topic
  Future<String> sendTopicNotification({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) {
    return fcmSender.sendToTopic(
      topic: topic,
      title: title,
      body: body,
      data: data,
    );
  }

  /// 🔹 Send a notification to a single device
  Future<String> sendTokenNotification({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) {
    return fcmSender.sendToToken(
      token: token,
      title: title,
      body: body,
      data: data,
    );
  }

  /// 🔹 Send a notification to multiple device tokens (multicast)
  Future<String> sendMultipleTokensNotification({
    required List<String> tokens,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) {
    return fcmSender.sendToMultipleTokens(
      tokens: tokens,
      title: title,
      body: body,
      data: data,
    );
  }
}
