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

💊 عايز علاجك يوصلك لحد باب البيت؟

📸 ابعت صورة الروشتة هنا أو من خلال تطبيق *لينك*، وهنبعتلك سعر كل دواء وإجمالي الطلب خلال دقائق ⏱️

💳 تقدر تدفع بسهولة عن طريق *إنستا باي* أو *المحفظة الإلكترونية*.

🚚 نوصل علاجك لحد باب البيت مقابل *5 جنيه فقط*.

🧾 الروشتة والأدوية المصروفة هتفضل محفوظة عندك في تطبيق لينك وعند الدكتور، حتى لو ضاعت الروشتة تقدر ترجع لها في أي وقت.

📍 التوصيل متاح حاليًا داخل *طنطا* وجاري التوسع لباقي المناطق قريبًا 💙
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
        final patientCode = reservation.patientCode;
        final codeLine =
            (patientCode != null && patientCode.isNotEmpty)
                ? "\n🗂️ كود الحالة: *$patientCode*"
                : "";

        final baseMessage = """
📌 تم تأكيد حجزك يا $patientName 💙

👨‍⚕️ عند *د. $doctorName*
🔢 رقم الحجز: *$orderNum*$codeLine

📱 تقدر تتابع دورك مباشرة من تطبيق *لينك* وتعرف فاضلك كام مريض قبل الكشف.

🔔 هيوصلك تحديثات وإشعارات لحظية مع كل حالة تخلص قبلك، وكمان عند وصول الدكتور للعيادة، عشان تيجي في الوقت المناسب بدون انتظار طويل.

💊 بعد الكشف ابعت صورة الروشتة من التطبيق أو واتساب، وهنوصّل العلاج لحد باب البيت بسعر توصيل *5 جنيه فقط* 🚚

🧾 الروشتة والأدوية المصروفة هتتحفظ تلقائيًا على حسابك في تطبيق لينك وعلى ملفك عند الدكتور، عشان تقدر ترجع لها في أي وقت حتى لو الروشتة ضاعت منك أو نسيت اسم دواء أخدته قبل كده.
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
