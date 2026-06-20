import 'dart:math';
import 'package:diwanclinic/index/index_main.dart';

class WhatsAppStatusMessageService {
  static final _random = Random();

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
    String? cancelReason,
  }) async {
    try {
      final rawPhone = reservation.patientPhone ?? "";
      if (rawPhone.isEmpty) return;
      final phone = _formatPhone(rawPhone);
      final patientName = reservation.patientName ?? 'the_patient'.tr;
      final doctorName = reservation.doctorName ?? 'the_clinic'.tr;
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
        cancelReason: cancelReason,
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
    String? cancelReason,
  }) {
    final hasApp = _hasApp(reservation);
    final orderNum = reservation.orderNum?.toString() ?? "-";
    final patientCode = reservation.patientCode;
    final codeLine =
        (patientCode != null && patientCode.isNotEmpty)
            ? "\n🗂️ كود الحالة: *$patientCode*"
            : "";

    switch (status) {
      case ReservationStatus.approved:
        final variants = _approvedVariants(
          patientName: patientName,
          doctorName: doctorName,
          orderNum: orderNum,
          codeLine: codeLine,
          phone: phone,
          androidLink: androidLink,
          iosLink: iosLink,
          hasApp: hasApp,
        );
        return variants[_random.nextInt(variants.length)];

      case ReservationStatus.completed:
        final variants = _completedVariants(
          patientName: patientName,
          doctorName: doctorName,
          phone: phone,
          androidLink: androidLink,
          iosLink: iosLink,
          hasApp: hasApp,
        );
        return variants[_random.nextInt(variants.length)];

      case ReservationStatus.cancelledByAssistant:
      case ReservationStatus.cancelledByDoctor:
        return _buildCancelledMessage(
          patientName: patientName,
          doctorName: doctorName,
          orderNum: orderNum,
          cancelReason: cancelReason,
        );

      default:
        return null;
    }
  }

  // ============================================================
  // CANCELLED — رسالة إلغاء مع السبب
  // ============================================================
  static String _buildCancelledMessage({
    required String patientName,
    required String doctorName,
    required String orderNum,
    String? cancelReason,
  }) {
    final reasonLine =
        (cancelReason != null && cancelReason.isNotEmpty)
            ? "\n📋 السبب: *$cancelReason*"
            : "";
    return "عزيزي/ـتي $patientName،\n\nنعتذر منك بشدة 🙏\nتم إلغاء حجزك رقم *$orderNum* عند *د. $doctorName*.$reasonLine\n\nيمكنك إعادة الحجز في أي وقت من التطبيق أو بالتواصل معنا مباشرة.\n\nشكراً لتفهمك 💙";
  }

  // ============================================================
  // APPROVED — 8 نسخ مختلفة
  // ============================================================
  static List<String> _approvedVariants({
    required String patientName,
    required String doctorName,
    required String orderNum,
    required String codeLine,
    required String phone,
    required String androidLink,
    required String iosLink,
    required bool hasApp,
  }) {
    final app =
        hasApp
            ? ""
            : _buildAppLinks(
              phone: phone,
              androidLink: androidLink,
              iosLink: iosLink,
            );

    return [
      "📌 تم تأكيد حجزك يا $patientName 💙\n\n👨‍⚕️ عند *د. $doctorName*\n🔢 رقم الحجز: *$orderNum*$codeLine\n\n📱 تابع دورك لحظة بلحظة من تطبيق *لينك*\n🔔 هيوصلك إشعار تلقائي كل ما اتخلصت حالة قبلك، وعند وصول الدكتور للعيادة\n\n🏠 تقدر كمان تحجز موعدك الجاي من بيتك من غير ما تيجي\n$app",
      "✅ حجزك اتأكد يا $patientName 🎉\n\n🩺 *د. $doctorName* هيستناك\n🔢 رقم دورك: *$orderNum*$codeLine\n\n👀 من تطبيق *لينك* شوف فاضلك كام مريض وانت في بيتك\n⏰ ابعت لما يكون دورك قرّب، مش هتحتاج تستنى زيادة في العيادة\n\n🏡 وللمرة الجاية تقدر تحجز من التطبيق براحتك\n$app",
      "مرحباً يا $patientName 👋\n\n✅ تم تأكيد موعدك عند *د. $doctorName*\n📌 رقم الحجز: *$orderNum*$codeLine\n\n⏱️ مش محتاج تستنى في العيادة من الأول\nافتح تطبيق *لينك* وتابع دورك وانت في مكانك\n🔔 إشعار تلقائي أول ما يقرب دورك\n\n🏠 حجز موعد الجاي متاح من التطبيق في أي وقت\n$app",
      "💙 أهلاً $patientName\n\nحجزك اتأكد ✅ عند *د. $doctorName*\n🔢 الرقم التسلسلي: *$orderNum*$codeLine\n\n🟢 تابع دورك على تطبيق *لينك* من راحتك\nالتطبيق بيبعتلك إشعار لحظي:\n• كل ما حالة تخلص قبلك\n• وعند وصول الدكتور للعيادة\n\n🏠 للحجز الجاي مش هتحتاج تيجي العيادة، تحجز من التطبيق\n$app",
      "السلام عليكم يا $patientName 🌿\n\nتم تأكيد موعدك ✅\n👨‍⚕️ *د. $doctorName*\n🔢 رقم الحجز: *$orderNum*$codeLine\n\n💡 نصيحة: متجيش العيادة من الأول وتستنى\nمن تطبيق *لينك* اتابع دورك وانت في بيتك، وهييجي إشعار أوتوماتيك لما يقرب وقتك\n\n📲 كمان تقدر تحجز للمرة الجاية من التطبيق بدون ما تيجي\n$app",
      "يا $patientName، حجزك اتأكد 💚\n\n👨‍⚕️ *د. $doctorName* هيشوفك\n🔢 رقم الدور: *$orderNum*$codeLine\n\n🔔 التطبيق بيبعتلك إشعار لحظي كل ما اتخلصت حالة قبلك\nمش محتاج تفضل مستني في العيادة من الأول\n\n📱 تطبيق *لينك* — تابع دورك وحجز الجاي من بيتك 🏡\n$app",
      "تأكيد الحجز - $patientName 📋\n\n🏥 *د. $doctorName*\n🔢 رقمك: *$orderNum*$codeLine\n\nتطبيق *لينك* هيوفرلك وقتك:\n📍 تعرف دورك وانت في بيتك\n🔔 إشعار فوري كل ما اتخلصت حالة\n🏠 حجز موعد جديد من أي مكان\n\n$app",
      "تمام يا $patientName ✅\n\nحجزك اتأكد عند *د. $doctorName* 💙\n🔢 رقمك: *$orderNum*$codeLine\n\nمش لازم تفضل قاعد في العيادة من الأول\nافتح تطبيق *لينك* وشوف فاضلك كام مريض من بيتك 🏠\n🔔 إشعار تلقائي عند وصول الدكتور وعند كل حالة تخلص\n\n$app",
    ];
  }

  // ============================================================
  // COMPLETED — ألف سلامة — 8 نسخ مختلفة
  // ============================================================
  static List<String> _completedVariants({
    required String patientName,
    required String doctorName,
    required String phone,
    required String androidLink,
    required String iosLink,
    required bool hasApp,
  }) {
    final app =
        hasApp
            ? ""
            : _buildAppLinks(
              phone: phone,
              androidLink: androidLink,
              iosLink: iosLink,
            );

    return [
      "🎉 ألف سلامة عليك يا $patientName 💙\n\n👨‍⚕️ من عيادة *د. $doctorName*\nتم الانتهاء من الكشف بنجاح ✅\n\n🏠 المرة الجاية تقدر تحجز موعدك من بيتك من تطبيق *لينك* بدون ما تيجي العيادة\n🔔 التطبيق بيبعتلك إشعار لحظي وانت في الطريق\n$app",
      "سلامتك يا $patientName 🌿\n\nنتمنى لك الصحة والعافية دايماً 💚\nشكراً لزيارتك لـ *د. $doctorName* ✅\n\n📲 للحجز الجاي، تطبيق *لينك* هيوفرلك وقتك\nحجز من بيتك وتابع دورك من غير انتظار 🏡\n$app",
      "ألف سلامة يا $patientName 🤍\n\nالكشف اتخلص بخير عند *د. $doctorName* ✅\n\n🏠 محتاج زيارة تانية؟ حجز من تطبيق *لينك* من بيتك في أي وقت\nالتطبيق بيبعتلك إشعار تلقائي أول ما يقرب دورك 🔔\n$app",
      "💙 سلامتك يا $patientName\n\nتم إنهاء كشفك بنجاح عند *د. $doctorName* ✅\n\n📱 تطبيق *لينك* جاهز دايماً:\n🏠 حجز موعد جديد من البيت\n🔔 متابعة دورك بإشعارات لحظية\n\n$app",
      "الحمد لله على السلامة يا $patientName 🌸\n\nانتهى كشفك بخير عند *د. $doctorName* ✅\n\n📲 في حالة محتجت حجز تاني، افتح تطبيق *لينك* وحجز من بيتك 🛋️\nوهتتابع دورك وانت في راحتك من غير ما تستنى في العيادة\n$app",
      "🎊 ربنا يشفيك يا $patientName\n\nتم الكشف ✅ عند *د. $doctorName*\n\n📍 للحجز الجاي مش لازم تيجي العيادة\nمن تطبيق *لينك* حجز وتابع دورك من مكانك 🏠\n$app",
      "سلامتك يا $patientName 💛\n\nزيارتك لـ *د. $doctorName* اتخلصت بخير ✅\n\n🔔 للمرة الجاية:\nحجز من تطبيق *لينك* وتابع دورك لحظة بلحظة من بيتك\nهييجي إشعار أوتوماتيك وانت في الطريق 📲\n$app",
      "💙 ألف سلامة عليك يا $patientName\n\nمن عيادة *د. $doctorName*، نتمنى لك الصحة والعافية 🌿\n\n🏠 للحجز الجاي تقدر تحجز من تطبيق *لينك* براحتك\nوهتتابع دورك لحظة بلحظة بدون ما تحتاج تستنى في العيادة من الأول\n$app",
    ];
  }

  // ============================================================
  // MANUAL SEND — رسالة تأكيد ثابتة (بدون عشوائية) للإرسال اليدوي
  // ============================================================
  static String buildManualApprovedMessage(ReservationModel reservation) {
    const androidLink = Strings.url_android;
    const iosLink = Strings.url_ios;
    final patientName = reservation.patientName ?? 'المريض';
    final doctorName = reservation.doctorName ?? 'الدكتور';
    final orderNum = reservation.orderNum?.toString() ?? '-';
    final patientCode = reservation.patientCode;
    final codeLine =
        (patientCode != null && patientCode.isNotEmpty)
            ? '\n🗂️ كود الحالة: *$patientCode*'
            : '';
    final phone = reservation.patientPhone ?? '';
    final hasApp = _hasApp(reservation);
    final app =
        hasApp
            ? ''
            : _buildAppLinks(
              phone: phone,
              androidLink: androidLink,
              iosLink: iosLink,
            );

    return '📌 تم تأكيد حجزك يا $patientName 💙\n\n'
        '👨‍⚕️ عند *د. $doctorName*\n'
        '🔢 رقم الحجز: *$orderNum*$codeLine\n\n'
        '📱 تابع دورك لحظة بلحظة من تطبيق *لينك*\n'
        '🔔 هيوصلك إشعار تلقائي كل ما اتخلصت حالة قبلك، وعند وصول الدكتور للعيادة\n\n'
        '🏠 تقدر كمان تحجز موعدك الجاي من بيتك من غير ما تيجي\n'
        '$app';
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
    return "\n\n📱 حمّل تطبيق *لينك* وابدأ:\n\n👤 اسم المستخدم: *رقم موبايلك*\n🔐 كلمة السر: *نفس الرقم*\n📞 رقمك: $phone\n\n⚠️ *متعملش حساب جديد* — بس افتح التطبيق وسجل دخول برقمك على طول\n\n📲 أندرويد: $androidLink\n🍎 آيفون: $iosLink\n\n📌 من التطبيق تقدر:\n• تتابع دورك أول بأول\n• تحجز من بيتك\n\n";
  }
}
