import '../../../index/index_main.dart';

class WhatsAppReservationMessages {
  static String build({
    required ReservationStatus status,
    required ReservationModel reservation,
    required ClinicModel? clinic,
  }) {
    final patient = reservation.patientName ?? "المريض";
    final phone = reservation.patientPhone ?? "";
    final doctor = reservation.doctorName ?? "العيادة";

    switch (status) {
      case ReservationStatus.approved:
        return _approved(patient, doctor, reservation, phone);

      case ReservationStatus.inProgress:
        return _inProgress(patient, doctor, reservation, phone);

      case ReservationStatus.completed:
        return _completed(patient, doctor, phone);

      case ReservationStatus.cancelledByAssistant:
      case ReservationStatus.cancelledByDoctor:
      case ReservationStatus.cancelledByUser:
        return _cancelled(patient, doctor);

      default:
        return "";
    }
  }

  // ------------------------------------------------------------------

  static String _approved(
    String patient,
    String doctor,
    ReservationModel r,
    String phone,
  ) {
    final ahead = (r.orderReserved != null) ? (r.orderReserved! - 1) : null;

    final queueText =
        ahead == null
            ? "سيتم إعلامك بدورك قريبًا."
            : (ahead == 0 ? "دورك الآن ✨" : "قدامك $ahead حالات.");

    return """
👨‍⚕️ *عيادة د. $doctor*

تم تأكيد حجزك يا *$patient* ✅  
🧾 رقم الحجز: ${r.orderNum ?? "-"}

👥 $queueText

بعد انتهاء الكشف:
🎁 خصم حتى 10%
🚚 توصيل لحد باب البيت

📲 حمّل تطبيق لينك:
Android: ${Strings.url_android}
iOS: ${Strings.url_ios}

🔑 الدخول برقمك: $phone
""";
  }

  static String _inProgress(
    String patient,
    String doctor,
    ReservationModel r,
    String phone,
  ) {
    return """
⏳ *جاري الكشف الآن*

يا *$patient*  
الكشف بدأ عند د. *$doctor* 👨‍⚕️

بعد الانتهاء تقدر:
💊 تطلب علاجك
🎁 تستفيد بخصم
🚚 توصلك لحد البيت

📲 تطبيق لينك:
Android: ${Strings.url_android}
iOS: ${Strings.url_ios}
""";
  }

  static String _completed(String patient, String doctor, String phone) {
    return """
✅ *تم الانتهاء من الكشف*

نتمنى لك السلامة يا *$patient* 🌿  
تقدر دلوقتي تطلب العلاج من تطبيق *لينك*

🎁 خصم حتى 10%
🚚 توصيل سريع

📲 التطبيق:
Android: ${Strings.url_android}
iOS: ${Strings.url_ios}

🔑 الدخول برقمك: $phone
""";
  }

  static String _cancelled(String patient, String doctor) {
    return """
❌ *تم إلغاء الحجز*

يا *$patient*  
تم إلغاء الحجز لدى د. *$doctor*

لو حابب تحجز مرة تانية:
📲 استخدم تطبيق لينك
""";
  }
}
