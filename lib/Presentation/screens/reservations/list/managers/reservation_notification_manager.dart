import '../../../../../index/index_main.dart';

class NotificationCleanupService {
  static Future<void> removeReservationNotifications({
    required String reservationKey,
  }) async {
    final service = ParentNotificationService();

    await service.getNotificationsData(
      data: FirebaseFilter(orderBy: "reservation_key", equalTo: reservationKey),
      query: SQLiteQueryParams(),
      voidCallBack: (list) async {
        for (final notif in list) {
          if (notif?.key == null) continue;

          await service.deleteNotificationData(
            notificationKey: notif!.key!,
            voidCallBack: (_) {
              Loader.dismiss();
              NotificationController controller = initController(
                () => NotificationController(),
              );
              controller.update();
            },
          );
        }
      },
    );
  }
}
