import 'package:firebase_database/firebase_database.dart';
import '../../index/index_main.dart';

class ChatService {
  // ============================================================
  // 🧠 RESOLVE CURRENT USER UID
  // ============================================================

  String _resolveUid() {
    final user = Get.find<UserSession>().user?.user;

    if (user == null) {
      throw Exception("❌ No logged in user");
    }

    if (user is DoctorUser) {
      return user.uid!;
    }

    if (user is AssistantUser) {
      return user.doctorKey!;
    }

    return user.uid!;
  }

  // ============================================================
  // 📁 ROOT REF
  // ============================================================

  DatabaseReference get _db =>
      FirebaseDatabase.instance.ref("${_resolveUid()}/chats");

  // ============================================================
  // 🔑 CHAT ID
  // ============================================================

  String getChatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return "${sorted[0]}_${sorted[1]}";
  }

  // ============================================================
  // 📥 GET USER CHATS
  // ============================================================

  Stream<List<ChatThread>> getUserChats(String uid) {
    return FirebaseDatabase.instance
        .ref("$uid/chats")
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return [];

      return data.values.map((chat) {
        final map = Map<String, dynamic>.from(chat as Map);

        return ChatThread(
          receiverId: map["receiverId"],
          receiverName: map["receiverName"],
          lastMessage: map["lastMessage"],
          lastMessageTime: map["lastMessageTime"],
          isRead: map["isRead"] ?? true,
        );
      }).toList();
    });
  }

  // ============================================================
  // 📤 SEND MESSAGE
  // ============================================================

  Future<void> sendMessage(ChatMessage message) async {
    final chatId = getChatId(message.senderId, message.receiverId);

    final chatRef = _db.child(chatId);

    // Save message
    await chatRef.child("messages").push().set(message.toJson());

    // Update metadata
    await chatRef.update({
      "lastMessage": message.text,
      "lastMessageTime": message.timestamp,
      "receiverId": message.receiverId,
      "receiverName": message.receiverName ?? "مريض",
      "senderId": message.senderId,
      "senderName": message.senderName ?? "دكتور",
      "participants": {
        message.senderId: true,
        message.receiverId: true,
      },
      "isRead": false,
    });
  }

  // ============================================================
  // 💬 GET MESSAGES
  // ============================================================

  Stream<List<ChatMessage>> getMessages(String uid1, String uid2) {
    final chatId = getChatId(uid1, uid2);

    return _db.child(chatId).child("messages").onValue.map((event) {
      if (event.snapshot.value == null) return [];

      final data =
      Map<String, dynamic>.from(event.snapshot.value as Map);

      return data.entries.map((e) {
        return ChatMessage.fromJson(
          Map<String, dynamic>.from(e.value),
          e.key,
        );
      }).toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    });
  }
}