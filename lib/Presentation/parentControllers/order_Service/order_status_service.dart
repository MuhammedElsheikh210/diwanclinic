import '../../../index/index_main.dart';

class OrderStatusService {
  static Future<void> updateOrderStatus({
    required OrderModel order,
    required String newStatus,
    required Future<void> Function(OrderModel updatedOrder) onSave,
  }) async {
    Loader.show();

    final updated = order.copyWith(
      status: newStatus,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    // 🔔 Push + Save notification
    await _sendPushAndSave(updated);

    // 💬 WhatsApp (ORDER → صيدلية)
    await _sendOrderWhatsApp(updated);

    // 💾 حفظ الأوردر
    await onSave(updated);

    Loader.dismiss();
    Loader.showSuccess("تم تحديث حالة الطلب إلى ${_statusLabel(newStatus)}");
  }

  // ===========================================================================
  // 🔔 PUSH + SAVE NOTIFICATION
  // ===========================================================================
  static Future<void> _sendPushAndSave(OrderModel order) async {
    final token = order.pharmacyFcmToken ?? "";
    final toKey = order.patientuid;
    final userType = LocalUser().getUserData().userType?.name == "pharmacy";

    if (token.isEmpty || toKey == null) return;

    final notificationService = NotificationManagerService();
    final parentService = ParentNotificationService();

    await notificationService.sendToToken(
      token: userType ? order.fcmToken ?? "" : token,
      title: _notificationTitle(order.status),
      body: _notificationBody(order),
      voidCallBack: (status) async {
        if (status != ResponseStatus.success) return;

        final notification = NotificationModel.newNotification(
          title: _notificationTitle(order.status),
          body: _notificationBody(order),
          toKey: toKey,
          userType: userType ? "pharmacy" : "patient",
          notificationType: order.status ?? "order_update",
          extraData: order.toJson(),
        );

        await parentService.addNotificationData(
          notification: notification,
          voidCallBack: (_) {},
        );
      },
    );
  }

  // ===========================================================================
  // 💬 WHATSAPP (ORDER → PHARMACY)
  // ===========================================================================
  static Future<void> _sendOrderWhatsApp(OrderModel order) async {
    await WhatsAppOrderMessageService.sendNewOrderMessage(order: order);
  }

  // ===========================================================================
  // 🔤 HELPERS
  // ===========================================================================
  static String _statusLabel(String? status) {
    switch (status) {
      case "pending":
        return "قيد الانتظار";

      case "processing":
        return "جاري حساب السعر";

      case "calculated":
        return "في انتظار الموافقة";

      case "confirmed":
        return "تمت الموافقة من العميل";

      case "approved":
        return "جاري التنفيذ";

      case "delivered":
        return "تم التوصيل";

      case "completed":
        return "تم إرسال الطلب";

      case "cancelled":
        return "ملغي";

      default:
        return status ?? "غير معروف";
    }
  }

  // ===========================================================================
  // 🔔 NOTIFICATION TITLES
  // ===========================================================================
  static String _notificationTitle(String? status) {
    switch (status) {
      case "pending":
        return "تم استلام الروشتة";

      case "processing":
        return "جاري حساب سعر الروشتة";

      case "calculated":
        return "تم تسعير الروشتة";

      case "confirmed":
        return "تمت موافقة العميل على السعر";

      case "approved":
        return "جاري تجهيز الطلب";

      case "delivered":
        return "تم توصيل الطلب";

      case "completed":
        return "تم إغلاق الطلب";

      case "cancelled":
        return "تم إلغاء الطلب";

      default:
        return "تحديث على طلب الروشتة";
    }
  }

  static String _notificationBody(OrderModel order) {
    switch (order.status) {
      // 🕓 المريض بعت الروشتة
      case "pending":
        return "تم استلام الروشتة الخاصة بك، وسيتم مراجعتها من الصيدلية قريبًا.";

      // 💰 الصيدلية بتسعّر
      case "processing":
        return "الصيدلية تعمل حاليًا على تسعير الروشتة الخاصة بك.";

      // 🧮 السعر اتحسب
      case "calculated":
        return "تم تسعير الروشتة. برجاء مراجعة السعر والموافقة لإكمال الطلب.";

      // ✅ العميل وافق
      case "confirmed":
        return "تمت موافقتك على السعر، وجاري تجهيز طلبك الآن.";

      // 🚚 الصيدلية بدأت التنفيذ
      case "approved":
        return "جاري تجهيز طلبك وتجهيزه للتوصيل.";

      // 📦 الطلب في الطريق
      case "delivered":
        return "تم توصيل طلبك بنجاح، نتمنى لك الشفاء العاجل.";

      // 🔒 تم الإغلاق
      case "completed":
        return "تم خروج الطلب بنجاح. شكرًا لاستخدامك تطبيق لينك.";

      // ❌ إلغاء
      case "cancelled":
        return "تم إلغاء الطلب. في حالة وجود استفسار يمكنك التواصل معنا.";

      default:
        return "تم تحديث حالة طلب الروشتة الخاصة بك.";
    }
  }
}
