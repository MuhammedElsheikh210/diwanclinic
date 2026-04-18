import '../../../../index/index_main.dart';

class NotificationController extends GetxController {
  final NotificationPatentService _service = NotificationPatentService();

  List<NotificationModel?> notifications = [];

  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();

  /// 🔔 unread notifications count
  int get unreadCount => notifications.where((n) => n?.isRead == false).length;

  // ─────────────────────────────────────────────
  // INIT
  // ─────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _initRealtime();
  }

  Future<void> markAllAsRead() async {
    final unread = notifications.where((n) => n?.isRead == false).toList();

    if (unread.isEmpty) return;

    for (final notif in unread) {
      final updated = notif!.copyWith(isRead: true);
      print("updated model is ${updated.toJson()}");

      await _service.updateNotificationData(
        notification: updated,
        voidCallBack: (_) {},
      );
    }

    notifications =
        notifications.map((n) => n?.copyWith(isRead: true)).toList();

    update();
  }

  void _initRealtime() async {
    await _service.startListening();

    _service.onNotificationAdded = (model) {
      onRealtimeAdd(model);
    };

    _service.onNotificationUpdated = (model) {
      onRealtimeUpdate(model);
    };

    _service.onNotificationRemoved = (key) {
      onRealtimeDelete(key);
    };
  }

  // ─────────────────────────────────────────────
  // REALTIME HANDLERS
  // ─────────────────────────────────────────────

  void onRealtimeAdd(NotificationModel model) {
    final exists = notifications.any((n) => n?.key == model.key);
    if (exists) return;

    notifications.insert(0, model);
    _sort();
    update();
  }

  void onRealtimeUpdate(NotificationModel model) {
    notifications =
        notifications.map((n) => n?.key == model.key ? model : n).toList();
    _sort();
    update();
  }

  void onRealtimeDelete(String notificationKey) {
    notifications.removeWhere((n) => n?.key == notificationKey);
    update();
  }

  void _sort() {
    notifications.sort(
      (a, b) => (b?.createAt ?? 0).compareTo(a?.createAt ?? 0),
    );
  }

  // ─────────────────────────────────────────────
  // MARK AS READ
  // ─────────────────────────────────────────────

  Future<void> markAsRead(NotificationModel notif) async {
    final updated = notif.copyWith(isRead: true);

    await _service.updateNotificationData(
      notification: updated,
      voidCallBack: (_) {},
    );

    notifications =
        notifications.map((n) => n?.key == notif.key ? updated : n).toList();

    update();
  }

  Future<void> _markNotificationAsRead(String key) async {
    final notif = notifications.firstWhereOrNull((n) => n?.key == key);
    if (notif == null) return;

    final updated = notif.copyWith(isRead: true);

    await _service.updateNotificationData(
      notification: updated,
      voidCallBack: (_) {},
    );

    notifications =
        notifications.map((n) => n?.key == key ? updated : n).toList();

    update();
  }

  // ─────────────────────────────────────────────
  // ➕ ADD NOTIFICATION (MANUAL / SYSTEM)
  // ─────────────────────────────────────────────

  Future<void> addNotification({
    required String title,
    required String body,
    required String toKey,
    String? notificationType,
    Map<String, dynamic>? extraData,
  }) async {
    final user = Get.find<UserSession>().user;

    final newNotif = NotificationModel(
      key: const Uuid().v4(),
      fromKey: user?.uid,
      toKey: toKey,
      title: title,
      body: body,
      notificationType: notificationType,
      extraData: extraData,
      userType: user?.name,
      createAt: DateTime.now().millisecondsSinceEpoch,
      isRead: false,
    );

    await _service.addNotificationData(
      notification: newNotif,
      voidCallBack: (_) {},
    );
  }

  // ─────────────────────────────────────────────
  // CLEAN UP
  // ─────────────────────────────────────────────

  @override
  void onClose() {
    titleController.dispose();
    bodyController.dispose();
    _service.dispose();
    super.onClose();
  }
}

extension NotificationFeature on NotificationController {
  // ─────────────────────────────────────────────
  // FETCH NOTIFICATIONS
  // ─────────────────────────────────────────────
  // Future<void> getNotifications() async {
  //   isLoading = true;
  //   update();
  //
  //   final user = LocalUser().getUserData();
  //   final bool isAssistant = user.userType?.name == "assistant";
  //   final userKey = isAssistant ? (user.uid ?? "") : (user.uid ?? "");
  //
  //   await _service.getNotificationsData(
  //     data: FirebaseFilter(orderBy: "to_key", equalTo: userKey),
  //     query: SQLiteQueryParams(is_filtered: true),
  //     isFiltered: true,
  //     voidCallBack: (data) {
  //       data.sort((a, b) {
  //         final aTime = a?.createAt ?? 0;
  //         final bTime = b?.createAt ?? 0;
  //         return bTime.compareTo(aTime);
  //       });
  //
  //       notifications = data;
  //       isLoading = false;
  //       update();
  //     },
  //   );
  // }

  // ─────────────────────────────────────────────
  // APPROVE
  // ─────────────────────────────────────────────
  Future<void> approveReservationFromNotification(
    ReservationModel reservation,
    String notificationKey,
  ) async {
    Loader.show();

    final nextOrderNum = await _getNextOrderNum(
      date: reservation.appointmentDateTime ?? "",
      clinicKey: reservation.clinicKey ?? "",
    );

    final updated = reservation.copyWith(
      status: ReservationStatus.approved.value,
    );
    updated.assistantUid = Get.find<UserSession>().user?.uid;

    await ReservationService().updateReservationData(
      reservation: updated,
      voidCallBack: (_) async {
        await _afterApprove(updated, notificationKey);


        // 📱 WhatsApp
        await WhatsAppStatusMessageService.sendStatusWhatsAppMessage(
          reservation: updated,
          clinic: null, // أو clinic لو متاحة
          from_assist: true, // 👈 مهمة
          newStatus: ReservationStatus.approved,
        );
      },
    );
  }

  Future<void> _afterApprove(
    ReservationModel reservation,
    String notificationKey,
  ) async {
    final updated = reservation.copyWith(
      status: ReservationStatus.approved.value,
    );

    await PatientReservationService().updateReservationData(
      reservation: updated,
      voidCallBack: (_) async {
        // ✅ تحديث الإشعار
        await _updateNotificationAfterAction(
          notificationKey: notificationKey,
          newStatus: ReservationStatus.approved.value,
        );

        // 🔥 حذف باقي إشعارات نفس الحجز
        await _removeOtherReservationNotifications(
          reservationKey: reservation.key!,
          exceptNotificationKey: notificationKey,
        );

        Loader.dismiss();
        Loader.showSuccess("تم قبول الحجز");
      },
    );
  }

  Future<void> _removeOtherReservationNotifications({
    required String reservationKey,
    required String exceptNotificationKey,
  }) async {
    // 1️⃣ هات كل الإشعارات الخاصة بنفس الحجز
    await _service.getNotificationsOnlineData(
      firebaseFilter: FirebaseFilter(
        orderBy: "reservation_key",
        equalTo: reservationKey,
      ),
      voidCallBack: (list) async {
        for (final notif in list) {
          if (notif == null) continue;

          // ❌ سيب الإشعار اللي اتقبل منه الحجز
          if (notif.key == exceptNotificationKey) continue;

          // 🗑️ احذف باقي الإشعارات
          await _service.deleteNotificationData(
            notificationKey: notif.key!,
            voidCallBack: (_) {},
          );
        }
      },
    );
  }

  // ─────────────────────────────────────────────
  // REJECT
  // ─────────────────────────────────────────────
  Future<void> rejectReservationFromNotification(
    ReservationModel reservation,
    String notificationKey,
  ) async {
    Loader.show();

    final updated = reservation.copyWith(
      status: ReservationStatus.cancelledByAssistant.value,
    );
    updated.assistantUid = Get.find<UserSession>().user?.uid;
    await ReservationService().updateReservationData(
      reservation: updated,
      voidCallBack: (_) async {
        await _afterReject(updated, notificationKey);

        final notificationController = Get.find<NotificationController>();

        // await notificationController.addNotification(
        //   title: "تم إلغاء الحجز",
        //   body: "نعتذر، تم إلغاء الحجز.\nيمكنك الحجز مرة أخرى بسهولة 🙏",
        //   toKey: updated.patientUid ?? "",
        //   notificationType: ReservationStatus.cancelledByAssistant.value,
        //   extraData: updated.toJson(),
        // );

        // 📱 WhatsApp
        await WhatsAppStatusMessageService.sendStatusWhatsAppMessage(
          reservation: updated,
          clinic: null,
          from_assist: true,
          newStatus: ReservationStatus.cancelledByAssistant,
        );
      },
    );
  }

  Future<void> _afterReject(
    ReservationModel reservation,
    String notificationKey,
  ) async {
    final updated = reservation.copyWith(
      status: ReservationStatus.cancelledByAssistant.value,
    );

    // 👤 Update Patient (copy)
    await PatientReservationService().updateReservationData(
      reservation: updated,
      voidCallBack: (_) async {
        // ✅ تحديث الإشعار
        await _updateNotificationAfterAction(
          notificationKey: notificationKey,
          newStatus: ReservationStatus.cancelledByAssistant.value,
        );

        Loader.dismiss();
        Loader.showSuccess("تم رفض الحجز");
      },
    );
  }

  Future<void> _updateNotificationAfterAction({
    required String notificationKey,
    required String newStatus,
  }) async {
    final notif = notifications.firstWhereOrNull(
      (n) => n?.key == notificationKey,
    );
    if (notif == null) return;

    Map<String, dynamic>? extra = notif.extraData;

    if (extra != null) {
      extra = Map<String, dynamic>.from(extra);
      extra["status"] = newStatus;
    }

    final updated = notif.copyWith(isRead: true, extraData: extra);

    await _service.updateNotificationData(
      notification: updated,
      voidCallBack: (_) {},
    );

    notifications =
        notifications
            .map((n) => n?.key == notificationKey ? updated : n)
            .toList();

    update();
  }

  // ─────────────────────────────────────────────
  // ORDER NUMBER
  // ─────────────────────────────────────────────
  Future<int> _getNextOrderNum({
    required String date,
    required String clinicKey,
  }) async {
    int lastOrderNum = 0;

    await ReservationService().getReservationsData(
      query: SQLiteQueryParams(
        is_filtered: true,
        where: """
        clinic_key = ?
        AND appointment_date_time = ?
        AND status IN (?, ?)
      """,
        whereArgs: [
          clinicKey,
          date,
          ReservationStatus.approved.value,
          ReservationStatus.inProgress.value,
        ],
      ),
      voidCallBack: (list) {
        if (list.isEmpty) {
          lastOrderNum = 0;
          return;
        }

        lastOrderNum = list
            .map((r) => int.tryParse(r?.orderNum?.toString() ?? "0") ?? 0)
            .reduce((a, b) => a > b ? a : b);
      },
    );

    return lastOrderNum + 1;
  }

  // ─────────────────────────────────────────────
  // CONFIRM DIALOGS
  // ─────────────────────────────────────────────
  Future<void> confirmApproveReservation({
    required BuildContext context,
    required ReservationModel reservation,
    required String notificationKey,
  }) async {
    final confirmed = await _showConfirmDialog(
      context: context,
      title: "تأكيد القبول",
      message: "هل أنت متأكد من قبول هذا الحجز وإدخاله في قائمة الانتظار؟",
      confirmText: "قبول الحجز",
      confirmColor: AppColors.primary,
    );

    if (!confirmed) return;

    await approveReservationFromNotification(reservation, notificationKey);
  }

  Future<void> confirmRejectReservation({
    required BuildContext context,
    required ReservationModel reservation,
    required String notificationKey,
  }) async {
    final confirmed = await _showConfirmDialog(
      context: context,
      title: "تأكيد الرفض",
      message: "هل أنت متأكد من رفض هذا الحجز؟ لا يمكن التراجع عن هذا الإجراء.",
      confirmText: "رفض الحجز",
      confirmColor: AppColors.errorBackground,
    );

    if (!confirmed) return;

    await rejectReservationFromNotification(reservation, notificationKey);
  }

  // ─────────────────────────────────────────────
  // DIALOG
  // ─────────────────────────────────────────────
  Future<bool> _showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            title: Text(title, style: context.typography.lgBold),
            content: Text(message, style: context.typography.mdRegular),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("إلغاء"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
                onPressed: () => Navigator.pop(context, true),
                child: Text(confirmText),
              ),
            ],
          ),
    );

    return result ?? false;
  }
}
