import 'package:diwanclinic/Presentation/parentControllers/parent_notification_service.dart';
import 'package:diwanclinic/Presentation/screens/notification/notification_sync_service.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../../index/index_main.dart';

class NotificationController extends GetxController {
  final ParentNotificationService _service = ParentNotificationService();

  List<NotificationModel?> notifications = [];

  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();

  /// 🔔 unread notifications count
  int get unreadCount => notifications.where((n) => n?.isRead == false).length;

  // 🔄 Firebase listeners
  StreamSubscription<DatabaseEvent>? _addSub;
  StreamSubscription<DatabaseEvent>? _changeSub;
  StreamSubscription<DatabaseEvent>? _removeSub;

  // ─────────────────────────────────────────────
  // INIT
  // ─────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();

    fetchNotifications();
    final user = LocalUser().getUserData();
    final bool isAssistant = user.userType?.name == "assistant";
  }

  // ---------------------------------------------------------------------------
  // 📥 FETCH NOTIFICATIONS (REALTIME ONLY)
  // ---------------------------------------------------------------------------
  Future<void> fetchNotifications() async {
    final user = LocalUser().getUserData();
    final userKey = user.uid;

    if (userKey == null || userKey.isEmpty) {
      update();
      return;
    }

    update();

    final ref = FirebaseDatabase.instance.ref("notifications");

    /// 👇 1️⃣ check once if there is any data
    final snapshot = await ref.get();

    if (!snapshot.exists) {
      // 🔴 no notifications at all
      notifications.clear();
      update();
    }

    // 🟢 ADDED
    _addSub = ref.onChildAdded.listen((event) {
      if (event.snapshot.value == null) return;

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      if (data["to_key"] != userKey) return;

      final model = NotificationModel.fromJson(data)..key = event.snapshot.key;

      _upsertNotification(model);

      update();
    });

    // 🔄 UPDATED
    _changeSub = ref.onChildChanged.listen((event) {
      if (event.snapshot.value == null) return;

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      if (data["to_key"] != userKey) return;

      final model = NotificationModel.fromJson(data)..key = event.snapshot.key;

      _upsertNotification(model);
      update();
    });

    // ❌ REMOVED
    _removeSub = ref.onChildRemoved.listen((event) {
      final key = event.snapshot.key;
      if (key == null) return;

      notifications.removeWhere((n) => n?.key == key);
      update();
    });
  }

  // ---------------------------------------------------------------------------
  // 🔁 ADD OR UPDATE IN MEMORY
  // ---------------------------------------------------------------------------
  void _upsertNotification(NotificationModel model) {
    final index = notifications.indexWhere((n) => n?.key == model.key);

    if (index == -1) {
      notifications.insert(0, model);
    } else {
      notifications[index] = model;
    }

    // 🔽 newest → oldest
    notifications.sort(
      (a, b) => (b?.createAt ?? 0).compareTo(a?.createAt ?? 0),
    );
  }

  // ---------------------------------------------------------------------------
  // MARK AS READ (Firebase only)
  // ---------------------------------------------------------------------------
  Future<void> markAsRead(NotificationModel notif) async {
    await FirebaseDatabase.instance.ref("notifications/${notif.key}").update({
      "is_read": true,
    });
    // 🔥 realtime will update UI
  }

  void onRealtimeDelete(String notificationKey) {
    notifications.removeWhere((n) => n?.key == notificationKey);
    update();
  }

  // ─────────────────────────────────────────────
  // REALTIME
  // ─────────────────────────────────────────────
  void onRealtimeAdd(NotificationModel model) {
    final exists = notifications.any((n) => n?.key == model.key);
    if (exists) return;

    notifications.insert(0, model);
    update();
  }

  void onRealtimeUpdate(NotificationModel model) {
    notifications = notifications
        .map((n) => n?.key == model.key ? model : n)
        .toList();
    update();
  }

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
    updated.fcmToken_assist = LocalUser().getUserData().fcmToken;
    await ReservationService().updateReservationData(
      date: reservation.appointmentDateTime ?? "",
      reservation: updated,
      localOnly: false,
      voidCallBack: (_) async {
        await _afterApprove(updated, notificationKey);

        // 🔔 Push Notification
        await NotificationHandler().sendStatusNotification(
          newStatus: ReservationStatus.approved,
          reservation: updated,
          toToken: updated.fcmToken_patient ?? "",
        );

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
    await ReservationService().updatePatientReservationData(
      key: reservation.key ?? "",
      data: reservation.copyWith(status: ReservationStatus.approved.value),
      voidCallBack: (_) async {
        await _markNotificationAsRead(notificationKey);

        // 🔥 2) امسح باقي إشعارات نفس الحجز
        await _removeOtherReservationNotifications(
          reservationKey: reservation.key!,
          exceptNotificationKey: notificationKey,
        );

        Loader.dismiss();
        Loader.showSuccess("تم قبول الحجز");
        // getNotifications();
      },
    );
  }

  Future<void> _removeOtherReservationNotifications({
    required String reservationKey,
    required String exceptNotificationKey,
  }) async {
    // 1️⃣ هات كل الإشعارات الخاصة بنفس الحجز
    await _service.getNotificationsData(
      data: FirebaseFilter(orderBy: "reservation_key", equalTo: reservationKey),
      query: SQLiteQueryParams(),
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
    updated.fcmToken_assist = LocalUser().getUserData().fcmToken;
    await ReservationService().updateReservationData(
      date: reservation.appointmentDateTime ?? "",
      reservation: updated,
      localOnly: false,
      voidCallBack: (_) async {
        await _afterReject(updated, notificationKey);

        // 🔔 Push Notification
        await NotificationHandler().sendStatusNotification(
          newStatus: ReservationStatus.cancelledByAssistant,
          reservation: updated,
          toToken: updated.fcmToken_patient ?? "",
        );

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
    await ReservationService().updatePatientReservationData(
      key: reservation.key ?? "",
      data: reservation.copyWith(
        status: ReservationStatus.cancelledByAssistant.value,
      ),
      voidCallBack: (_) async {
        await _markNotificationAsRead(notificationKey);
        Loader.dismiss();
        Loader.showSuccess("تم رفض الحجز");
        //   getNotifications();
      },
    );
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
      date: date,
      data: FirebaseFilter(),
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
            .map((r) => int.tryParse(r?.order_num?.toString() ?? "0") ?? 0)
            .reduce((a, b) => a > b ? a : b);
      },
    );

    return lastOrderNum + 1;
  }

  // ─────────────────────────────────────────────
  // MARK AS READ
  // ─────────────────────────────────────────────
  Future<void> _markNotificationAsRead(String key) async {
    final notif = notifications.firstWhereOrNull((n) => n?.key == key);
    if (notif == null) return;

    final updated = notif.copyWith(isRead: true);

    await _service.addNotificationData(
      notification: updated,
      voidCallBack: (_) {},
    );

    notifications = notifications
        .map((n) => n?.key == key ? updated : n)
        .toList();

    update();
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
  // ➕ ADD NOTIFICATION (MANUAL / SYSTEM)
  // ─────────────────────────────────────────────
  Future<void> addNotification({
    required String title,
    required String body,
    required String toKey,
    String? notificationType,
    Map<String, dynamic>? extraData,
  }) async {
    final user = LocalUser().getUserData();

    final newNotif = NotificationModel(
      key: const Uuid().v4(),
      fromKey: user.key,
      toKey: toKey,
      title: title,
      body: body,
      notificationType: notificationType,
      extraData: extraData,
      userType: user.userType?.name,
      createAt: DateTime.now().millisecondsSinceEpoch,
      isRead: false,
    );

    await _service.addNotificationData(
      notification: newNotif,
      voidCallBack: (status) {
        if (status == ResponseStatus.success) {
          // getNotifications(); // refresh local list
        }
      },
    );
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
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

  // ─────────────────────────────────────────────
  // CLEAN UP
  // ─────────────────────────────────────────────
  @override
  void onClose() {
    titleController.dispose();
    bodyController.dispose();
    super.onClose();
  }
}
