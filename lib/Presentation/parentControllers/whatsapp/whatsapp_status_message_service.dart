import 'package:diwanclinic/index/index_main.dart';

class WhatsAppStatusMessageService {
  static String _formatPhone(String phone) {
    var p = phone.trim();

    if (p.startsWith("+")) return p;
    if (p.startsWith("20")) return "+$p";
    if (p.startsWith("0")) return "+2$p";

    return "+2$p";
  }

  static Future<void> sendStatusWhatsAppMessage({
    required ReservationModel reservation,
    required ClinicModel? clinic,
    bool? from_assist,
    required ReservationStatus newStatus,
    ReservationStatus? previousStatus,
  }) async {
    try {
      final rawPhone = reservation.patientPhone ?? "";
      if (rawPhone.isEmpty) return;

      final phone = _formatPhone(rawPhone);

      final patientName = reservation.patientName ?? "المريض";
      final doctorName = reservation.doctorName ?? "العيادة";

      const androidLink = Strings.url_android;
      const iosLink = Strings.url_ios;

      final message = _buildMessageByStatus(
        status: newStatus,
        previousStatus: previousStatus,
        doctorName: doctorName,
        patientName: patientName,
        phone: rawPhone,
        androidLink: androidLink,
        iosLink: iosLink,
        reservation: reservation,
      );

      if (message == null) return;

      await WhatsAppManager.sendMessage(to: phone, body: message);
    } catch (e) {}
  }

  static String? _buildMessageByStatus({
    required ReservationStatus status,
    required ReservationStatus? previousStatus,
    required String doctorName,
    required String patientName,
    required String phone,
    required String androidLink,
    required String iosLink,
    required ReservationModel reservation,
  }) {
    final hasApp = _hasApp(reservation);

    switch (status) {
      // ============================================================
      // ✅ COMPLETED (After كشف - أهم رسالة)
      // ============================================================
      case ReservationStatus.completed:
        final baseMessage = """
🎉 ألف سلامة عليك يا $patientName 💙  

👨‍⚕️ من عيادة *د. $doctorName*  
تم الانتهاء من الكشف بنجاح ✅  

💊 علاجك ممكن يوصلك لحد باب البيت  
*بنفس سعر الصيدلية + توصيل مجاني* 🚚  

📱 ابعتلنا الروشتة دلوقتي 📸  
وهنبعتلك السعر فورًا 💰  

✔️ وافق والتوصيل لحد عندك  

🎁 كود: *DR-${doctorName.replaceAll(" ", "").toUpperCase()}*  
علشان التوصيل يفضل مجاني  
""";

        if (hasApp) return baseMessage;

        return baseMessage +
            _buildAppLinks(
              phone: phone,
              androidLink: androidLink,
              iosLink: iosLink,
            );

      // ============================================================
      // ✅ APPROVED (حجز)
      // ============================================================
      case ReservationStatus.approved:
        final orderNum = reservation.orderNum ?? "-";

        final baseMessage = """
📌 حجزك اتسجل بنجاح يا $patientName 💙  

👨‍⚕️ عند *د. $doctorName*  
🔢 رقمك: *$orderNum*  

⏳ تابع دورك بسهولة من تطبيق *لينك*  
📡 التحديث بيتم لحظيًا  

💊 بعد الكشف  
ممكن تبعتلنا الروشتة  
ونوصلك العلاج لحد البيت 🚚  

✨ بدون تعب أو انتظار  
""";

        if (hasApp) return baseMessage;

        return baseMessage +
            _buildAppLinks(
              phone: phone,
              androidLink: androidLink,
              iosLink: iosLink,
            );

      default:
        return null;
    }
  }

  static bool _hasApp(ReservationModel reservation) {
    return reservation.patientFcm != null &&
        reservation.patientFcm!.trim().isNotEmpty;
  }

  static String _buildAppLinks({
    required String phone,
    required String androidLink,
    required String iosLink,
  }) {
    return """

📱 ادخل على التطبيق بسهولة:
👤 اسم المستخدم: *رقم موبايلك*  
🔐 كلمة السر: *نفس الرقم*

📞 رقمك: $phone

📲 أندرويد: $androidLink  
🍎 آيفون: $iosLink
""";
  }
}

// ============================================================================
// 📦 ORDERS WHATSAPP
// ============================================================================

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
      case "pending":
        return "🛒 تم استلام طلبك وجاري المراجعة.";

      case "processing":
        return "💰 جاري تسعير الروشتة… هيجيلك السعر خلال لحظات.";

      case "calculated":
        return """
🧾 تم تسعير الروشتة  

💵 الإجمالي: ${total?.toStringAsFixed(2) ?? "-"} جنيه  

✔️ وافق لبدء التجهيز فورًا
""";

      case "confirmed":
        return "✅ تم تأكيد الطلب وجاري التجهيز.";

      case "approved":
        return "📦 طلبك تحت التجهيز الآن.";

      case "completed":
        return """
🚚 طلبك خرج للتوصيل  

⏱️ هيوصلك خلال 15 – 45 دقيقة  

شكراً لاستخدامك لينك 💙
""";

      case "delivered":
        return "🌸 تم التوصيل بنجاح، ألف سلامة عليك.";

      case "cancelled":
        return "❌ تم إلغاء الطلب، لأي استفسار تواصل معنا.";

      default:
        return "";
    }
  }
}
