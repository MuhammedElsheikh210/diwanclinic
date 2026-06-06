import 'package:diwanclinic/Presentation/parentControllers/chat_service.dart';
import '../../../index/index_main.dart';

class AssistantChatDetailVm extends GetxController {
  final _chatService = ChatService();

  List<ChatMessage> messages = [];

  void listenMessages(String patientUid, String doctorKey) {
    _chatService
        .getAssistantMessages(patientUid, doctorKey)
        .listen((data) {
      messages = data;
      update();
    });
  }

  Future<void> sendMessage({
    required String text,
    required String senderId,
    required String receiverId,
    required String assistantId,
    required String assistantName,
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

    await _chatService.sendAssistantMessage(
      message: msg,
      doctorKey: assistantId,
      assistantName: assistantName,
      senderFcmToken: senderFcmToken,
      receiverFcmToken: receiverFcmToken,
    );
  }

  Future<void> markAssistantRead(String doctorKey, String chatId) =>
      _chatService.markAssistantChatRead(doctorKey, chatId);

  Future<void> markPatientRead(String patientUid, String chatId) =>
      _chatService.markPatientAssistantChatRead(patientUid, chatId);
}
