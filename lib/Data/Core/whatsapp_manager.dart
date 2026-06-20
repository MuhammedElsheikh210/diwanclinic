import 'package:cloud_functions/cloud_functions.dart';

class WhatsAppManager {
  // ============================================================
  // 📞 NORMALIZE PHONE — Egyptian numbers
  // ============================================================

  static String normalizeEgyptPhone(String phone) {
    phone = phone.trim();
    if (phone.startsWith("+")) phone = phone.substring(1);
    if (phone.startsWith("00")) phone = phone.substring(2);
    if (phone.startsWith("0")) phone = "20${phone.substring(1)}";
    if (!phone.startsWith("20")) phone = "20$phone";
    return phone;
  }

  // ============================================================
  // 📤 SEND MESSAGE — via Firebase Cloud Function (Meta API)
  // ============================================================

  static Future<bool> sendMessage({
    required String to,
    required String body,
  }) async {
    try {
      final phone = normalizeEgyptPhone(to);

      await FirebaseFunctions.instance
          .httpsCallable('sendWhatsAppMessage')
          .call({'to': phone, 'body': body});

      return true;
    } catch (e) {
      return false;
    }
  }

  // alias للـ backward compatibility
  static String formatNumber(String phone) => normalizeEgyptPhone(phone);

  // ============================================================
  // 📤 SEND TO MULTIPLE NUMBERS
  // ============================================================

  static Future<void> sendToMultiple({
    required List<String> numbers,
    required String message,
  }) async {
    for (final number in numbers) {
      await sendMessage(to: number, body: message);
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  // ============================================================
  // 📤 SEND TEMPLATE (bold title + message)
  // ============================================================

  static Future<bool> sendTemplate({
    required String to,
    required String title,
    required String message,
  }) async {
    final formatted = "*$title*\n\n$message";
    return sendMessage(to: to, body: formatted);
  }
}
