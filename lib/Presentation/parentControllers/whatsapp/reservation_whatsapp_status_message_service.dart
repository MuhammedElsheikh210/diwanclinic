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
تم الانتهاء من الكشف ✅  

💊 عايز علاجك يوصلك لحد باب البيت؟  
*بنفس سعر الصيدلية* 🚚  

📸 ابعت صورة الروشتة هنا حالًا  
وهنبعتلك السعر في دقيقة ⏱️  

✔️ استلم علاجك لحد البيت بدون مشوار أو انتظار  

🧾 ولو طلبت من عندنا  
الروشتة بتتسجل على تطبيق الدكتور  
وتقدر ترجع لها وتتابع علاجك بسهولة  

📍 التوصيل متاح حاليًا داخل *طنطا*  
وجاري التوسع لباقي المناطق قريبًا  

🚚 التوصيل مجاني حسب قيمة الطلب 💙  
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
📌 تم تسجيل حجزك يا $patientName 💙  

👨‍⚕️ عند *د. $doctorName*  
🔢 رقمك: *$orderNum*  

📱 تقدر تتابع دورك من خلال تطبيق *لينك*  
وتشوف فاضلك قد إيه على دخولك بدل ما تستنى كتير 👌  

🔔 هيجيلك إشعار من التطبيق يقولك دورك وصل لفين  
عشان تيجي في الوقت المناسب  

🏠 المرة الجاية تقدر تحجز من بيتك  
وتيجي على دورك على طول  

💊 بعد الكشف  
تقدر تبعت الروشتة من التطبيق أو واتساب  
ونوصل لك العلاج لحد البيت 🚚  
(غالبًا التوصيل مجاني)

🧾 ولو طلبت من عندنا  
الروشتة بتتسجل على تطبيق الدكتور  
📊 وتقدر تتابع علاجك وتشوف أخدت إيه وفاضل إيه بسهولة  
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

📱 حمّل تطبيق لينك وابدأ بسهولة:

👤 اسم المستخدم: *رقم موبايلك*  
🔐 كلمة السر: *نفس الرقم*  

📞 رقمك: $phone  

📲 أندرويد: $androidLink  
🍎 آيفون: $iosLink  

📌 من التطبيق تقدر:
• تتابع دورك أول بأول  
• تحجز من بيتك  
• تبعت الروشتة وتستلم العلاج لحد البيت  

""";
  }
}
