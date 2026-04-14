import 'package:diwanclinic/index/index_main.dart';

class WhatsAppStatusMessageService {
  /// 🔧 Format Egyptian phone number with +2
  static String _formatPhone(String phone) {
    var p = phone.trim();

    if (p.startsWith("+")) return p;
    if (p.startsWith("20")) return "+$p";
    if (p.startsWith("0")) return "+2$p";

    return "+2$p";
  }

  /// 🔥 Main shared method
  static Future<void> sendStatusWhatsAppMessage({
    required ReservationModel reservation,
    required ClinicModel? clinic,
    bool? from_assist,
    required ReservationStatus newStatus,
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
        doctorName: doctorName,
        patientName: patientName,
        phone: rawPhone,
        // 👈 نسيبها للمسج من غير +2
        from_assist: from_assist,
        androidLink: androidLink,
        iosLink: iosLink,
        reservation: reservation,
      );

      await WhatsAppManager.sendMessage(to: phone, body: message);
    } catch (e) {
      print("❌ WhatsApp Error: $e");
    }
  }

  /// 🔥 Build a smart WhatsApp message
  static String _buildMessageByStatus({
    required ReservationStatus status,
    required String doctorName,
    required String patientName,
    required String phone,
    bool? from_assist,
    required String androidLink,
    required String iosLink,
    required ReservationModel reservation,
  }) {
    final hasApp = _hasApp(reservation);

    switch (status) {
    // ============================================================
    // ✅ COMPLETED
    // ============================================================
      case ReservationStatus.completed:
        final baseMessage = """
👨‍⚕️ *من عيادة د. $doctorName*
الكشف خلص يا $patientName، وتقدر الآن تطلب علاجك بخصم يصل ل 10٪؜ ويوصلك لحد البيت 🚚
""";

        if (hasApp) return baseMessage;

        return baseMessage +
            _buildAppLinks(
              phone: phone,
              androidLink: androidLink,
              iosLink: iosLink,
            );

    // ============================================================
    // ✅ APPROVED
    // ============================================================
      case ReservationStatus.approved:
        final orderNum = reservation.orderNum ?? "-";

        final baseMessage = from_assist == true
            ? """
⏳ *تم تسجيل حجزك يا $patientName* عند د. $doctorName ✔️

🔢 *رقم حجزك:* $orderNum  
تابع دورك بسهولة من تطبيق *لينك*  
الدور بيتحدّث باستمرار.

🎁 بعد الكشف تقدر تطلب العلاج  
بخصم يوصل لـ *10%* 🚚
"""
            : """
⏳ *تم استلام حجزك يا $patientName* عند د. $doctorName ✔️

🔢 *رقم الحجز:* $orderNum  
تابع دورك أول بأول من تطبيق *لينك* 📱
""";

        if (hasApp) return baseMessage;

        return baseMessage +
            _buildAppLinks(
              phone: phone,
              androidLink: androidLink,
              iosLink: iosLink,
            );

    // ============================================================
    // 🔁 DEFAULT
    // ============================================================
      default:
        return "تم تحديث حالة الحجز.";
    }
  }

// ============================================================
// 🔧 HELPERS
// ============================================================

  /// ✅ Check if patient has app
  static bool _hasApp(ReservationModel reservation) {
    return reservation.patientFcm != null &&
        reservation.patientFcm!.trim().isNotEmpty;
  }

  /// ✅ Build app links block
  static String _buildAppLinks({
    required String phone,
    required String androidLink,
    required String iosLink,
  }) {
    return """

📱 *طريقة الدخول للتطبيق:*
✍️ اسم المستخدم: *رقم الموبايل*  
🔐 كلمة السر: *رقم الموبايل نفسه*  
(اكتب نفس الرقم في الخانتين)

📞 رقمك: $phone

📱 أندرويد: $androidLink  
🍎 آيفون: $iosLink
""";
  }
}

// ============================================================================
// 📦 ORDERS WHATSAPP
// ============================================================================
class WhatsAppOrderMessageService {
  /// 🔧 Format phone
  static String _formatPhone(String phone) {
    var p = phone.trim();
    if (p.startsWith("+")) return p;
    if (p.startsWith("20")) return "+$p";
    if (p.startsWith("0")) return "+2$p";
    return "+2$p";
  }

  /// 💬 Send WhatsApp message based on order status
  static Future<void> sendNewOrderMessage({required OrderModel order}) async {
    try {
      final isPharmacy =
          Get.find<UserSession>().user?.user.userType == UserType.pharmacy;
      final rawPhone =
          isPharmacy ? order.phone ?? "" : order.pharmacyPhone ?? "";

      if (rawPhone.isEmpty) return;

      final phone = _formatPhone(rawPhone);
      final message = _buildMessageByStatus(order);
      print("phone is ${phone}");

      if (message.isEmpty) return;

      await WhatsAppManager.sendMessage(to: phone, body: message);
    } catch (e) {
      debugPrint("❌ WhatsApp Order Error: $e");
    }
  }

  // ===========================================================================
  // 🧠 MESSAGE BUILDER
  // ===========================================================================
  static String _buildMessageByStatus(OrderModel order) {
    final status = order.status;
    final total = order.totalOrder;

    switch (status) {
      case "pending":
        return """
🛒 *تم استلام طلب جديد*
⏳ الطلب قيد المراجعة حالياً.
""";

      case "processing":
        return """
💰 *جاري تسعير الروشتة*
⏳ يتم الآن تسعير الأدوية.
🔔 هيوصلك إشعار فور الانتهاء.
""";

      case "calculated":
        return """
🧾 *تم تسعير الروشتة*

💵 *الإجمالي:* ${total?.toStringAsFixed(2) ?? "-"} جنيه
⏳ في انتظار الموافقة.
""";

      case "confirmed":
        return """
✅ *تمت الموافقة على السعر*
📦 جاري تجهيز الطلب.
""";

      case "approved":
        return """
🚚 *الطلب قيد التجهيز*

📦 الصيدلية استلمت طلبك وبدأت تسعيره.
🔔 هيجيلك إشعار فور الانتهاء.
⚡ برجاء التأكيد بسرعة لبدء التوصيل.
""";

      case "delivered":
        return """
📦 *تم توصيل الطلب بنجاح*
نتمنى لك الشفاء العاجل 🌸
""";

      case "completed":
        return """
🚚 *طلبك خرج للتوصيل*
الأوردر في الطريق وهيوصلك خلال
⏱️ من *15* إلى *45 دقيقة*

شكراً لاستخدامك *لينك* 💙
""";

      case "cancelled":
        return """
❌ *تم إلغاء الطلب*
لو في أي مشكلة تواصل معنا.
""";

      default:
        return "";
    }
  }
}
