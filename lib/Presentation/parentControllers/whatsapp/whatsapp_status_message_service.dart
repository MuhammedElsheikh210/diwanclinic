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
        from_assist: from_assist,
        androidLink: androidLink,
        iosLink: iosLink,
        reservation: reservation,
      );

      if (message == null) return;

      await WhatsAppManager.sendMessage(to: phone, body: message);
    } catch (e) {
      print("❌ WhatsApp Error: $e");
    }
  }

  static String? _buildMessageByStatus({
    required ReservationStatus status,
    required ReservationStatus? previousStatus,
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
🎉 *ألف سلامة عليك يا $patientName!*

👨‍⚕️ من عيادة *د. $doctorName*  
تم الانتهاء من الكشف بنجاح ✅

💊 *هنبعتلك علاجك بسهولة لحد البيت 👇*

📱 اضغط *اطلب علاجك* من التطبيق  
📸 صوّر الروشتة وارفعها  
💰 وهنبعتلك السعر في ثواني  
✔️ وافق على الطلب  
🚚 ويوصلك لحد باب البيت بخصم يصل الي 10%*
✨ كل ده وانت في مكانك 💙
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
        final isFromPending =
            previousStatus == ReservationStatus.pending;

        final baseMessage =
        isFromPending
            ? """
✅ *تم تأكيد حجزك يا $patientName!*

👨‍⚕️ عند *د. $doctorName*  
🔢 رقم الحجز: *$orderNum*

⏳ تابع دورك لحظة بلحظة من تطبيق *لينك*  
وخليك جاهز… دورك قرب 😉

💊 *بعد الكشف هنبعتلك علاجك بسهولة لحد البيت 👇*

📱 اضغط *اطلب علاجك* من التطبيق  
📸 صوّر الروشتة وارفعها  
💰 وهنبعتلك السعر في ثواني  
✔️ وافق على الطلب  
🚚 ويوصلك لحد باب البيت بخصم يصل الي 10%*

📲 حمل التطبيق وابدأ:
"""
            : """
📌 *حجزك اتسجل بنجاح يا $patientName!*

👨‍⚕️ عند *د. $doctorName*  
🔢 رقمك في الكشف: *$orderNum*

⏳ تابع دورك بسهولة من تطبيق *لينك*  
📡 التحديث بيتم لحظيًا

💊 *بعد الكشف هنبعتلك علاجك بسهولة لحد البيت 👇*

📱 اضغط *اطلب علاجك* من التطبيق  
📸 صوّر الروشتة وارفعها  
💰 وهنبعتلك السعر في ثواني  

✔️ وافق على الطلب  
🚚 ويوصلك لحد باب البيت  

💸 *بخصم 10%*
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

📱 *ادخل على التطبيق بسهولة:*
👤 اسم المستخدم: *رقم موبايلك*  
🔐 كلمة السر: *نفس الرقم*

📞 رقمك: $phone

📲 أندرويد: $androidLink  
🍎 آيفون: $iosLink
""";
  }
}// 📦 ORDERS WHATSAPP
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
