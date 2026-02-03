import '../../../../../../../index/index_main.dart';

class NotificationHandler {
  final ReservationModel reservation;

  NotificationHandler({
    required this.reservation,
  });

  // ---------------------------------------------------------------------------
  // 🟠 send FCM + save notification
  // ---------------------------------------------------------------------------
  Future<void> sendStatusNotification({
    required ReservationStatus newStatus,
  }) async {
    final token = await ConstantsData.firebaseToken() ?? "";
    if (token.isEmpty) return;

    final notificationService = NotificationManagerService();

    String title = "";
    String body = "";

    switch (newStatus) {
      case ReservationStatus.approved:
        title = "تم تأكيد الحجز";
        body =
        "تم تأكيد حجزك رقم ${reservation.order_num} بنجاح. ننتظرك في العيادة.";
        break;

      case ReservationStatus.inProgress:
        title = "بدأ الكشف";
        body =
        "بدأ الكشف لحجزك رقم ${reservation.order_num}. يرجى التوجه للطبيب.";
        break;

      case ReservationStatus.completed:
        return;

      case ReservationStatus.cancelledByAssistant:
        title = "تم إلغاء الحجز";
        body = "تم إلغاء حجزك رقم ${reservation.order_num} بواسطة المساعد.";
        break;

      case ReservationStatus.cancelledByDoctor:
        title = "تم إلغاء الحجز";
        body = "تم إلغاء حجزك رقم ${reservation.order_num} بواسطة الطبيب.";
        break;

      case ReservationStatus.cancelledByUser:
        title = "إلغاء من المريض";
        body = "تم إلغاء الحجز رقم ${reservation.order_num} بواسطة المريض.";
        break;

      case ReservationStatus.pending:
        title = "في انتظار التأكيد";
        body = "حجزك رقم ${reservation.order_num} قيد المراجعة للتأكيد.";
        break;
    }

    notificationService.sendToToken(
      token: token,
      title: title,
      body: body,
      voidCallBack: (status) async {
        if (status == ResponseStatus.success) {
          final notification = NotificationModel.newNotification(
            title: title,
            body: body,
            toKey: reservation.patientKey,
            userType: "assistant",
            notificationType: newStatus.value,
            extraData: {
              "reservation_key": reservation.key ?? "",
              "order_num": reservation.order_num ?? "",
              "clinic_key": reservation.clinicKey ?? "",
              "status": newStatus.value,
            },
          );

          await ParentNotificationService().addNotificationData(
            notification: notification,
            voidCallBack: (_) {},
          );
        }
      },
    );
  }
}
