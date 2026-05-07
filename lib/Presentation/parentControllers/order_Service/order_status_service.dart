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
    // await _sendPushAndSave(updated);

    // 💬 WhatsApp (ORDER → صيدلية)
    await _sendOrderWhatsApp(updated);

    // 💾 حفظ الأوردر
    await onSave(updated);

    Loader.dismiss();
    Loader.showSuccess("تم تحديث حالة الطلب إلى ${_statusLabel(newStatus)}");
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
}
