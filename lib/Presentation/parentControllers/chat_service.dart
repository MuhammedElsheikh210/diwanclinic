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

  // ============================================================
  // 💊 PHARMACY CHAT SECTION
  // ============================================================

  /// Firebase path: pharmacy_chats/{pharmacyId}/chats/{chatId}/messages/
  DatabaseReference _pharmacyChatsRef(String pharmacyId) =>
      FirebaseDatabase.instance.ref("pharmacy_chats/$pharmacyId/chats");

  String pharmacyChatId(String patientUid, String pharmacyId) {
    final sorted = [patientUid, pharmacyId]..sort();
    return "${sorted[0]}_${sorted[1]}";
  }

  /// Send a message in a pharmacy chat (patient ↔ pharmacist)
  Future<void> sendPharmacyMessage({
    required ChatMessage message,
    required String pharmacyId,
    required String pharmacyName,
    String? senderFcmToken,
    String? receiverFcmToken, // ← token of the OTHER party
  }) async {
    final patientId = message.senderId == pharmacyId
        ? message.receiverId
        : message.senderId;
    final patientName = message.senderId == pharmacyId
        ? (message.receiverName ?? "مريض")
        : (message.senderName ?? "مريض");

    final chatId = pharmacyChatId(patientId, pharmacyId);
    final lastMsg = message.isImage ? "📷 صورة" : message.text;
    final isPharmacySender = message.senderId == pharmacyId;

    // ── Build thread metadata ──────────────────────────────────
    final Map<String, dynamic> threadData = {
      "lastMessage": lastMsg,
      "lastMessageTime": message.timestamp,
      "patientId": patientId,
      "patientName": patientName,
      "pharmacyId": pharmacyId,
      "pharmacyName": pharmacyName,
      "isPharmacyRead": isPharmacySender,
      "isPatientRead": !isPharmacySender,
    };

    // Store BOTH tokens so Cloud Function always has them
    if (isPharmacySender) {
      if (senderFcmToken != null) threadData["pharmacyFcmToken"] = senderFcmToken;
      if (receiverFcmToken != null) threadData["patientFcmToken"] = receiverFcmToken;
    } else {
      if (senderFcmToken != null) threadData["patientFcmToken"] = senderFcmToken;
      if (receiverFcmToken != null) threadData["pharmacyFcmToken"] = receiverFcmToken;
    }

    // ── 1. Update thread FIRST (so Cloud Function reads complete tokens) ──
    await _pharmacyChatsRef(pharmacyId).child(chatId).update(threadData);

    // ── 2. THEN write message (this fires the Cloud Function) ─────────────
    await _pharmacyChatsRef(pharmacyId)
        .child(chatId)
        .child("messages")
        .push()
        .set(message.toJson());

    // ── 3. Mirror for patient list view ───────────────────────────────────
    final Map<String, dynamic> mirrorData = Map.from(threadData);
    await FirebaseDatabase.instance
        .ref("patient_pharmacy_chats/$patientId/$chatId")
        .update(mirrorData);
  }

  /// Listen to messages inside a pharmacy chat
  Stream<List<ChatMessage>> getPharmacyMessages(
      String patientUid, String pharmacyId) {
    final chatId = pharmacyChatId(patientUid, pharmacyId);
    return _pharmacyChatsRef(pharmacyId)
        .child(chatId)
        .child("messages")
        .onValue
        .map((event) {
      if (event.snapshot.value == null) return [];
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      return data.entries
          .map((e) => ChatMessage.fromJson(
                Map<String, dynamic>.from(e.value),
                e.key,
              ))
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    });
  }

  /// Pharmacy side: all patient chat threads
  Stream<List<PharmacyChatThread>> getPharmacyChatList(String pharmacyId) {
    return _pharmacyChatsRef(pharmacyId).onValue.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return [];
      return data.values
          .map((c) => PharmacyChatThread.fromMap(
                Map<String, dynamic>.from(c as Map),
              ))
          .toList()
        ..sort((a, b) =>
            (b.lastMessageTime ?? 0).compareTo(a.lastMessageTime ?? 0));
    });
  }

  /// Patient side: all pharmacy chat threads
  Stream<List<PharmacyChatThread>> getPatientPharmacyChats(String patientUid) {
    return FirebaseDatabase.instance
        .ref("patient_pharmacy_chats/$patientUid")
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return [];
      return data.values
          .map((c) => PharmacyChatThread.fromMap(
                Map<String, dynamic>.from(c as Map),
              ))
          .toList()
        ..sort((a, b) =>
            (b.lastMessageTime ?? 0).compareTo(a.lastMessageTime ?? 0));
    });
  }

  /// Mark a pharmacy chat as read from pharmacy side
  Future<void> markPharmacyChatRead(String pharmacyId, String chatId) async {
    await _pharmacyChatsRef(pharmacyId)
        .child(chatId)
        .update({"isPharmacyRead": true});
  }

  /// Mark a pharmacy chat as read from patient side
  Future<void> markPatientPharmacyChatRead(
      String patientUid, String chatId) async {
    await FirebaseDatabase.instance
        .ref("patient_pharmacy_chats/$patientUid/$chatId")
        .update({"isPatientRead": true});
    // Also update on pharmacy side so pharmacist can see patient read it
    // We don't know pharmacyId here, so we update the patient mirror only
  }
}

// ============================================================
// 📦 PHARMACY CHAT THREAD MODEL
// ============================================================

class PharmacyChatThread {
  final String? patientId;
  final String? patientName;
  final String? pharmacyId;
  final String? pharmacyName;
  final String? lastMessage;
  final int? lastMessageTime;
  final bool? isPharmacyRead;
  final bool? isPatientRead;
  final String? patientFcmToken;
  final String? pharmacyFcmToken;

  const PharmacyChatThread({
    this.patientId,
    this.patientName,
    this.pharmacyId,
    this.pharmacyName,
    this.lastMessage,
    this.lastMessageTime,
    this.isPharmacyRead,
    this.isPatientRead,
    this.patientFcmToken,
    this.pharmacyFcmToken,
  });

  factory PharmacyChatThread.fromMap(Map<String, dynamic> map) {
    return PharmacyChatThread(
      patientId: map["patientId"],
      patientName: map["patientName"],
      pharmacyId: map["pharmacyId"],
      pharmacyName: map["pharmacyName"],
      lastMessage: map["lastMessage"],
      lastMessageTime: map["lastMessageTime"],
      isPharmacyRead: map["isPharmacyRead"] ?? true,
      isPatientRead: map["isPatientRead"] ?? true,
      patientFcmToken: map["patientFcmToken"],
      pharmacyFcmToken: map["pharmacyFcmToken"],
    );
  }
}