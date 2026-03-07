import '../../index/index_main.dart';

abstract class NotificationRemoteDataSource {
  // ============================================================
  // 🔹 CRUD (SERVER)
  // ============================================================

  Future<void> createNotification(NotificationModel model);

  Future<void> updateNotification(NotificationModel model);

  Future<void> deleteNotification(String key);

  // ============================================================
  // 🌐 FETCH (ONLINE READ)
  // ============================================================

  /// Fetch notifications from Firebase using filters
  /// Used for: First load / manual refresh
  Future<List<NotificationModel>> fetchNotifications(
    Map<String, dynamic> filters,
  );

  // ============================================================
  // 🎧 REALTIME CONTROL
  // ============================================================

  Future<void> startListening();

  Future<void> stopListening();

  // ============================================================
  // 🔥 REALTIME STREAMS
  // ============================================================

  Stream<NotificationModel> get onAdded;

  Stream<NotificationModel> get onChanged;

  Stream<String> get onRemoved;
}
