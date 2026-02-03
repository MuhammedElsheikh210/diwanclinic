import '../../../index/index_main.dart';

class WhatsAppOrderMessages {
  static String build(OrderModel order) {
    switch (order.status) {
      case "pending":
        return "🛒 تم استلام طلبك وهو قيد المراجعة.";

      case "processing":
        return "💰 جاري تسعير الروشتة، سيتم إشعارك قريبًا.";

      case "calculated":
        return """
🧾 تم تسعير الروشتة بنجاح

💊 إجمالي الأدوية: ${order.totalOrder?.toStringAsFixed(2) ?? "-"} ج.م
🏷️ الخصم: -${order.discount?.toStringAsFixed(2) ?? "0"} ج.م
🚚 التوصيل: ${order.deliveryFees?.toStringAsFixed(2) ?? "0"} ج.م
—————————————
💰 الإجمالي المطلوب: ${order.finalAmount?.toStringAsFixed(2) ?? "-"} ج.م

⏳ في انتظار موافقتك لإرسال الطلب
""";

      case "confirmed":
        return "✅ تم تأكيد السعر – جاري تجهيز الطلب.";

      case "approved":
        return "🚚 الطلب قيد التنفيذ الآن.";

      case "delivered":
        return "📦 تم توصيل الطلب بنجاح، نتمنى لك الشفاء 🌸";

      case "cancelled":
        return "❌ تم إلغاء الطلب.";

      default:
        return "";
    }
  }
}
