import 'package:diwanclinic/Data/Models/User_local/save_local_user.dart';
import 'package:diwanclinic/Presentation/screens/chat/chat_details/chat_view_model.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../index/index_main.dart';

class ChatService {
  final db = FirebaseDatabase.instance.ref(
    "${LocalUser().getUserData().uid ?? ""}/chats",
  );

  String getChatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return "${sorted[0]}_${sorted[1]}";
  }

  Stream<List<ChatThread>> getUserChats(String uid) {
    return FirebaseDatabase.instance
        .ref("$uid/chats") // ✅ correct path
        .onValue
        .map((event) {
          final data = event.snapshot.value as Map?;
          if (data == null) return [];

          return data.values.map((chat) {
            final map = chat as Map;
            return ChatThread(
              receiverId: map["receiverId"],
              receiverName: map["receiverName"],
              // make sure you save this
              lastMessage: map["lastMessage"],
              lastMessageTime: map["lastMessageTime"],
              isRead: map["isRead"] ?? true,
            );
          }).toList();
        });
  }

  Future<void> sendMessage(ChatMessage message) async {
    final chatId = getChatId(message.senderId, message.receiverId);

    final chatRef = db.child(chatId);

    // Save message
    await chatRef.child("messages").push().set(message.toJson());

    // Update chat metadata (for chat list preview)
    await chatRef.update({
      "lastMessage": message.text,
      "lastMessageTime": message.timestamp,
      "receiverId": message.receiverId,
      "receiverName": message.receiverName ?? "مريض", // 👈 add this
      "senderId": message.senderId,
      "senderName": message.senderName ?? "دكتور", // 👈 add this
      "participants": {message.senderId: true, message.receiverId: true},
      "isRead": false,
    });
  }

  Stream<List<ChatMessage>> getMessages(String uid1, String uid2) {
    final chatId = getChatId(uid1, uid2);
    return db.child(chatId).child("messages").onValue.map((event) {
      if (event.snapshot.value == null) return [];
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      return data.entries.map((e) {
        return ChatMessage.fromJson(Map<String, dynamic>.from(e.value), e.key);
      }).toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    });
  }
}
