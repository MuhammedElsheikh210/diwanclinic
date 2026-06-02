import 'package:diwanclinic/Presentation/parentControllers/chat_service.dart';
import '../../../index/index_main.dart';

class PharmacyChatDetailVm extends GetxController {
  final _chatService = ChatService();

  List<ChatMessage> messages = [];

  void listenMessages(String patientUid, String pharmacyId) {
    _chatService
        .getPharmacyMessages(patientUid, pharmacyId)
        .listen((data) {
      messages = data;
      update();
    });
  }

  Future<void> sendMessage({
    required String text,
    required String senderId,
    required String receiverId,
    required String pharmacyId,
    required String pharmacyName,
    bool isImage = false,
    String? senderName,
    String? receiverName,
    String? senderFcmToken,
    String? receiverFcmToken,
  }) async {
    if (text.trim().isEmpty && !isImage) return;

    final msg = ChatMessage(
      id: const Uuid().v4(),
      text: text,
      senderId: senderId,
      receiverId: receiverId,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      isImage: isImage,
      senderName: senderName,
      receiverName: receiverName,
    );

    // Thread is updated first, then message is written → Cloud Function
    // reads tokens correctly (no race condition).
    await _chatService.sendPharmacyMessage(
      message: msg,
      pharmacyId: pharmacyId,
      pharmacyName: pharmacyName,
      senderFcmToken: senderFcmToken,
      receiverFcmToken: receiverFcmToken,
    );
  }

  Future<void> markPharmacyRead(String pharmacyId, String chatId) =>
      _chatService.markPharmacyChatRead(pharmacyId, chatId);

  Future<void> markPatientRead(String patientUid, String chatId) =>
      _chatService.markPatientPharmacyChatRead(patientUid, chatId);
}
