import '../../index/index_main.dart';

class NotificationModel {
   String? key;                 // Unique notification ID
  final String? fromKey;             // Sender (doctor / assistant / admin)
  final String? toKey;               // Receiver (user / patient / assistant)
  final String? reservationKey;      // ✅ NEW: reservation reference
  final String? title;
  final String? body;
  final String? userType;            // doctor / assistant / patient / admin
  final int? createAt;
  final bool? isRead;
  final String? notificationType;
  final Map<String, dynamic>? extraData;

  NotificationModel({
    this.key,
    this.fromKey,
    this.toKey,
    this.reservationKey,
    this.title,
    this.body,
    this.userType,
    this.createAt,
    this.isRead = false,
    this.notificationType,
    this.extraData,
  });

  // ---------------------------------------------------------------------------
  // 🔹 TO JSON
  // ---------------------------------------------------------------------------
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    if (key != null) data['key'] = key;
    if (fromKey != null) data['from_key'] = fromKey;
    if (toKey != null) data['to_key'] = toKey;
    if (reservationKey != null) data['reservation_key'] = reservationKey;
    if (title != null) data['title'] = title;
    if (body != null) data['body'] = body;
    if (userType != null) data['user_type'] = userType;
    if (createAt != null) data['create_at'] = createAt;
    if (isRead != null) data['is_read'] = isRead;
    if (notificationType != null) data['notification_type'] = notificationType;
    if (extraData != null) data['extra_data'] = extraData;

    return data;
  }

  // ---------------------------------------------------------------------------
  // 🔹 FROM JSON
  // ---------------------------------------------------------------------------
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      key: json['key'],
      fromKey: json['from_key'],
      toKey: json['to_key'],
      reservationKey: json['reservation_key'],
      title: json['title'],
      body: json['body'],
      userType: json['user_type'],
      createAt: json['create_at'],
      isRead: json['is_read'] ?? false,
      notificationType: json['notification_type'],
      extraData: json['extra_data'] != null
          ? Map<String, dynamic>.from(json['extra_data'])
          : null,
    );
  }

  // ---------------------------------------------------------------------------
  // 🔹 COPY WITH
  // ---------------------------------------------------------------------------
  NotificationModel copyWith({
    String? key,
    String? fromKey,
    String? toKey,
    String? reservationKey,
    String? title,
    String? body,
    String? userType,
    int? createAt,
    bool? isRead,
    String? notificationType,
    Map<String, dynamic>? extraData,
  }) {
    return NotificationModel(
      key: key ?? this.key,
      fromKey: fromKey ?? this.fromKey,
      toKey: toKey ?? this.toKey,
      reservationKey: reservationKey ?? this.reservationKey,
      title: title ?? this.title,
      body: body ?? this.body,
      userType: userType ?? this.userType,
      createAt: createAt ?? this.createAt,
      isRead: isRead ?? this.isRead,
      notificationType: notificationType ?? this.notificationType,
      extraData: extraData ?? this.extraData,
    );
  }

  // ---------------------------------------------------------------------------
  // 🔹 FACTORY: CREATE NEW NOTIFICATION
  // ---------------------------------------------------------------------------
  factory NotificationModel.newNotification({
    required String title,
    required String body,
    String? toKey,
    String? reservationKey,
    String? key,
    String? userType,
    String? notificationType,
    Map<String, dynamic>? extraData,
  }) {
    final localUser = LocalUser().getUserData();

    return NotificationModel(
      key: key ?? const Uuid().v4(), // ✅ FIXED
      fromKey: localUser.key,
      toKey: toKey,
      reservationKey: reservationKey,
      title: title,
      body: body,
      userType: userType ?? localUser.userType?.name,
      createAt: DateTime.now().millisecondsSinceEpoch,
      isRead: false,
      notificationType: notificationType ?? 'general',
      extraData: extraData,
    );
  }
}
