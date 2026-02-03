import 'package:diwanclinic/Presentation/parentControllers/chat_service.dart';
import '../../../../index/index_main.dart';

class ChatViewModel extends GetxController {
  final ChatService _chatService = ChatService();

  // Messages inside one chat
  List<ChatMessage> messages = [];

  // All chat threads for ChatListView
  List<ChatThread>? chatList;

  /// 🔹 Listen to messages in a single chat
  void listenMessages(String uid1, String uid2) {
    _chatService.getMessages(uid1, uid2).listen((data) {
      messages = data;
      update();
    });
  }

  void sendMessage(
      String text,
      String senderId,
      String receiverId, {
        bool isImage = false,
        String? senderName,
        String? receiverName,
      }) {
    if (text.trim().isEmpty) return;

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

    _chatService.sendMessage(msg);
  }


  /// 🔹 Listen to all chat threads for current user
  void listenChats(String uid) {
    _chatService.getUserChats(uid).listen((data) {
      chatList = data;
      update();
    });
  }
}

/// 🔹 Model for chat threads in ChatListView
class ChatThread {
  final String? receiverId;
  final String? receiverName;
  final String? lastMessage;
  final int? lastMessageTime;
  final bool? isRead;

  ChatThread({
    this.receiverId,
    this.receiverName,
    this.lastMessage,
    this.lastMessageTime,
    this.isRead,
  });
}
