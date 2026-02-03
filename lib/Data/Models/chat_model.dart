class ChatMessage {
  final String id;
  final String text;
  final String senderId;
  final String receiverId;
  final int timestamp;
  final bool isImage;
  final String? senderName;   // 👈 add this
  final String? receiverName; // 👈 add this

  ChatMessage({
    required this.id,
    required this.text,
    required this.senderId,
    required this.receiverId,
    required this.timestamp,
    this.isImage = false,
    this.senderName,
    this.receiverName,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "text": text,
      "senderId": senderId,
      "receiverId": receiverId,
      "timestamp": timestamp,
      "isImage": isImage,
      "senderName": senderName,
      "receiverName": receiverName,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json, String key) {
    return ChatMessage(
      id: json["id"] ?? key,
      text: json["text"] ?? "",
      senderId: json["senderId"] ?? "",
      receiverId: json["receiverId"] ?? "",
      timestamp: json["timestamp"] ?? 0,
      isImage: json["isImage"] ?? false,
      senderName: json["senderName"],
      receiverName: json["receiverName"],
    );
  }
}
