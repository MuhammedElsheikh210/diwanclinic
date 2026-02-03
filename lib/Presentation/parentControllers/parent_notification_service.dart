// ignore_for_file: avoid_renaming_method_parameters

import 'package:diwanclinic/Domain/UseCases/notification_use_cases.dart';

import '../../index/index_main.dart';

class ParentNotificationService {
  final NotificationUseCases useCase = initController(
    () => NotificationUseCases(Get.find()),
  );

  // ─────────────────────────────────────────────
  // ➕ Add Notification
  // ─────────────────────────────────────────────
  Future<void> addNotificationData({
    required NotificationModel notification,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.addNotification(notification);
    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  // ─────────────────────────────────────────────
  // 🔁 Update Notification
  // ─────────────────────────────────────────────
  Future<void> updateNotificationData({
    required NotificationModel notification,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.updateNotification(notification);
    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  // ─────────────────────────────────────────────
  // 🗑️ Delete Notification
  // ─────────────────────────────────────────────
  Future<void> deleteNotificationData({
    required String notificationKey,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.deleteNotification(notificationKey);
    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  // ─────────────────────────────────────────────
  // 📥 Get Notifications
  // ─────────────────────────────────────────────
  Future<void> getNotificationsData({
    required FirebaseFilter data,
    required SQLiteQueryParams query,
    bool? isFiltered,
    required Function(List<NotificationModel?>) voidCallBack,
  }) async {
    // Loader.show();
    final result = await useCase.getNotifications(
      data.toJson(),
      query,
      isFiltered,
    );
    result.fold(
      (l) =>
          Loader.showError("Something went wrong while fetching notifications"),
      (r) => voidCallBack(r),
    );
  }
}
