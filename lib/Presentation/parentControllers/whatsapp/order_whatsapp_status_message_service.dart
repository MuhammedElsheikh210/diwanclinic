import 'package:diwanclinic/index/index_main.dart';

class WhatsAppOrderMessageService {
  static String _formatPhone(String phone) {
    var p = phone.trim();
    if (p.startsWith("+")) return p;
    if (p.startsWith("20")) return "+$p";
    if (p.startsWith("0")) return "+2$p";
    return "+2$p";
  }

  static Future<void> sendNewOrderMessage({required OrderModel order}) async {
    try {
      final isPharmacy =
          Get.find<UserSession>().user?.user.userType == UserType.pharmacy;
      final rawPhone =
          isPharmacy ? order.phone ?? "" : order.pharmacyPhone ?? "";

      if (rawPhone.isEmpty) return;

      final phone = _formatPhone(rawPhone);
      final message = _buildMessageByStatus(order);

      if (message.isEmpty) return;

      await WhatsAppManager.sendMessage(to: phone, body: message);
    } catch (e) {}
  }

  static String _buildMessageByStatus(OrderModel order) {
    final status = order.status;

    final total = order.totalOrder;

    switch (status) {
      // ============================================================
      // 🕓 NEW ORDER
      // ============================================================

      case "pending":
        return "🛒 تم استلام طلبك وجاري مراجعته من الصيدلية.";

      // ============================================================
      // 💰 PRICING
      // ============================================================

      case "processing":
        return "💰 جاري تسعير الروشتة الخاصة بك، هيجيلك السعر خلال لحظات.";

      // ============================================================
      // 🧾 PRICE READY
      // ============================================================

      case "calculated":
        return """
💵 إجمالي الطلب: ${total?.toStringAsFixed(2) ?? "-"} ج.م

📱 افتح تطبيق لينك لمشاهدة تفاصيل الروشتة والأدوية والأسعار كاملة.

💳 من داخل التطبيق يمكنك:
• الدفع كاش عند الاستلام
• الدفع عبر InstaPay
• الدفع بالمحفظة الإلكترونية

للتأكيد ارسل: 1
للإلغاء ارسل: 2

🚚 بمجرد التأكيد هنبدأ تجهيز الطلب والتوصيل فورًا.
""";

      // ============================================================
      // ✅ USER CONFIRMED
      // ============================================================

      case "confirmed":
        return "✅ تم تأكيد الطلب بنجاح، وجاري تجهيز الروشتة الآن.";

      // ============================================================
      // 📦 PREPARING
      // ============================================================

      case "approved":
        return "💰 جاري تسعير الروشتة الخاصة بك، هيجيلك السعر خلال لحظات.";
      // ============================================================
      // 🚚 OUT FOR DELIVERY
      // ============================================================

      case "completed":
        return """
🚚 طلبك خرج للتوصيل

⏱️ متوقع يوصل خلال 15 – 45 دقيقة

شكراً لاستخدامك لينك 💙
""";

      // ============================================================
      // 🌸 DELIVERED
      // ============================================================

      case "delivered":
        return "🌸 تم توصيل الطلب بنجاح، ألف سلامة عليك.";

      // ============================================================
      // ❌ CANCELLED
      // ============================================================

      case "cancelled":
        return order.cancel_reason ??
            "❌ تم إلغاء الطلب، لأي استفسار تواصل معنا.";

      default:
        return "";
    }
  }
}
