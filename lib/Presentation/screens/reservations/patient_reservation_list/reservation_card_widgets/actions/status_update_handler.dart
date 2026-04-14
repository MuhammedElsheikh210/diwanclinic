import '../../../../../../../index/index_main.dart';

class NotificationHandler {
  // ===========================================================================
  // 🔒 INTERNAL GENERIC SENDER (NO DUPLICATION)
  // ===========================================================================
  Future<void> _sendAndSave({
    required Future<void> Function(Function(ResponseStatus) callback)
    sendAction,
    required String toKey,
    required UserType userType,
    required String title,
    required String body,
    String? reservationKey,
    required String notificationType,
    required Map<String, dynamic> extraData,
  }) async {
    final parentService = NotificationPatentService();

    await sendAction((status) async {
      debugPrint("📬 FCM response → toKey=$toKey | status=$status");

      if (status != ResponseStatus.success) {
        debugPrint("❌ FCM FAILED → toKey=$toKey");
        return;
      }

      final notification = NotificationModel.newNotification(
        title: title,
        body: body,
        reservationKey: reservationKey,
        toKey: toKey,
        userType: userType,
        notificationType: notificationType,
        extraData: extraData,
      );

      await parentService.addNotificationData(
        notification: notification,
        voidCallBack: (saveStatus) {
          Loader.dismiss();
          debugPrint(
            "💾 Notification saved → toKey=$toKey | status=$saveStatus",
          );
        },
      );
    });
  }

  // ===========================================================================
  // 🟢 SEND TO ALL ASSISTANTS (TOKENS)
  // ===========================================================================
  Future<void> sendToClinicAssistants({
    required String title,
    required String body,
    required ReservationModel reservation,
    required List<LocalUser?> assistants,
    String notificationType = "new_reservation",
  }) async {
    if (assistants.isEmpty) {
      debugPrint("❌ assistants list is empty");
      return;
    }

    final notificationService = NotificationManagerService();

    for (final assistant in assistants) {
      if (assistant == null ||
          assistant.uid == null ||
          assistant.fcmToken == null ||
          assistant.fcmToken!.isEmpty) {
        debugPrint("❌ SKIP assistant (invalid uid/token)");
        continue;
      }

      final uid = assistant.uid!;
      final token = assistant.fcmToken!;

      debugPrint("📡 Sending to assistant uid=$uid");

      await _sendAndSave(
        toKey: uid,
        userType: UserType.patient,
        title: title,
        reservationKey: reservation.key,
        body: body,
        notificationType: notificationType,
        extraData: reservation.toJson(),
        sendAction: (callback) {
          return notificationService.sendToToken(
            token: token,
            title: title,
            body: body,
            voidCallBack: callback,
          );
        },
      );
    }
  }

  // ===========================================================================
  // 🟠 SEND STATUS TO PATIENT (TOKEN)
  // ===========================================================================
  Future<void> sendStatusNotification({
    required ReservationStatus newStatus,
    required ReservationModel reservation,
    required String toToken,
    String? cancelReason,
  }) async {
    final userKey = reservation.patientUid;
    if (toToken.isEmpty || userKey == null) return;

    final notificationService = NotificationManagerService();

    final titleBody = _statusText(newStatus, reservation);
    print("titleBody is ${titleBody}");
    if (titleBody == null) return;

    await _sendAndSave(
      toKey: userKey,
      userType: UserType.patient,
      title: titleBody.$1,
      body: titleBody.$2,
      notificationType: newStatus.value,
      extraData: reservation.toJson(),
      sendAction: (callback) {
        return notificationService.sendToToken(
          token: toToken,
          title: titleBody.$1,
          body: cancelReason ?? titleBody.$2,
          voidCallBack: callback,
        );
      },
    );
  }

  // ===========================================================================
  // 🟢 SEND TO CLINIC TOPIC
  // ===========================================================================
  Future<void> sendToClinicTopic({
    required String clinicKey,
    required String title,
    required String body,
    required ReservationModel reservation,
    String notificationType = "new_reservation",
  }) async {
    if (clinicKey.isEmpty) return;

    final notificationService = NotificationManagerService();
    final topic = "clinic_${clinicKey}";

    await _sendAndSave(
      toKey: topic,
      userType: UserType.clinic,
      title: title,
      body: body,
      notificationType: notificationType,
      extraData: reservation.toJson(),
      sendAction: (callback) {
        return notificationService.sendToTopic(
          topic: clinicKey,
          title: title,
          body: body,
          data: reservation.toJson(),
          voidCallBack: callback,
        );
      },
    );
  }

  Future<void> sendCustomNotification({
    required String toKey,
    required String toToken,
    required String title,
    required String body,
    required ReservationModel reservation,
    required String notificationType,
  }) async {
    final notificationService = NotificationManagerService();

    await _sendAndSave(
      toKey: toKey,
      userType: UserType.patient,
      title: title,
      body: body,
      reservationKey: reservation.key,
      notificationType: notificationType,
      extraData: reservation.toJson(),
      sendAction: (callback) {
        return notificationService.sendToToken(
          token: toToken,
          title: title,
          body: body,
          voidCallBack: callback,
        );
      },
    );
  }

  // ===========================================================================
  // 🔧 STATUS TEXT HELPER
  // ===========================================================================
  (String, String)? _statusText(ReservationStatus status, ReservationModel r) {
    switch (status) {
      case ReservationStatus.approved:
        return (
          "تم تأكيد الحجز",
          "تم تأكيد حجزك رقم ${r.orderNum} بنجاح. ننتظرك في العيادة.",
        );

      case ReservationStatus.inProgress:
        return (
          "بدأ الكشف",
          "بدأ الكشف لحجزك رقم ${r.orderNum}. يرجى التوجه للطبيب.",
        );

      case ReservationStatus.completed:
        return (
          "انتهاء الكشف",
          "تم الانتهاء من الكشف بنجاح. تقدر دلوقتي تطلب علاجك فورًا ويوصلك لحد البيت بسرعة، مع خصم يصل إلى 10٪ 🎁🚚",
        );

      case ReservationStatus.cancelledByAssistant:
        return (
          "تم إلغاء الحجز",
          "تم إلغاء حجزك رقم ${r.orderNum} بواسطة المساعد.",
        );

      case ReservationStatus.cancelledByDoctor:
        return (
          "تم إلغاء الحجز",
          "تم إلغاء حجزك رقم ${r.orderNum} بواسطة الطبيب.",
        );

      case ReservationStatus.cancelledByUser:
        return (
          "إلغاء من المريض",
          "تم إلغاء الحجز رقم ${r.orderNum} بواسطة المريض.",
        );

      case ReservationStatus.pending:
        return (
          "في انتظار التأكيد",
          "حجزك رقم ${r.orderNum} قيد المراجعة للتأكيد.",
        );
    }
  }
}
