// ignore_for_file: avoid_renaming_method_parameters

import '../../index/index_main.dart';

class NotificationManagerService {
  final NotificationSendRepository repo = NotificationSendRepository(
    FcmSenderService(
      projectId: 'pos-app-c2ced',
      serviceAccountPath: 'assets/config/${Strings.file_name}.json',
    ),
  );

  /// 🔹 Send notification to specific topic
  Future<void> sendToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    try {
      final result = await repo.sendTopicNotification(
        topic: topic,
        title: title,
        body: body,
        data: data ?? {},
      );

      Loader.dismiss();
      if (result.startsWith("✅")) {
        Loader.showSuccess("Sent successfully");
        voidCallBack(ResponseStatus.success);
      } else {
        Loader.showError(result);
        voidCallBack(ResponseStatus.error);
      }
    } catch (e) {
      Loader.showError("❌ Exception: $e");
      voidCallBack(ResponseStatus.error);
    }
  }

  /// 🔹 Send notification to single device token
  Future<void> sendToToken({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    try {
      final result = await repo.sendTokenNotification(
        token: token,
        title: title,
        body: body,
        data: data ?? {},
      );


      Loader.dismiss();
      if (result.startsWith("✅")) {
        voidCallBack(ResponseStatus.success);
      } else {
        Loader.showError(result);
        voidCallBack(ResponseStatus.error);
      }
    } catch (e) {
      Loader.showError("❌ Exception: $e");

      voidCallBack(ResponseStatus.error);
    }
  }
}
