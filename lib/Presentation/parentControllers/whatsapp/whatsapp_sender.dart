import '../../../index/index_main.dart';

class WhatsAppSender {
  static Future<void> send({
    required String phone,
    required String message,
  }) async {
    if (phone.isEmpty || message.isEmpty) return;

    try {
      await WhatsAppManager.sendMessage(
        to: phone,
        body: message,
      );
    } catch (e) {
      debugPrint("❌ WhatsApp send error: $e");
    }
  }
}
