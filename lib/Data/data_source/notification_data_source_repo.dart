
import '../../index/index_main.dart';

abstract class NotificationDataSourceRepo {
  /// 🔹 Get all or filtered notifications
  Future<List<NotificationModel?>> getNotifications(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      );

  /// 🔹 Add new notification
  Future<SuccessModel> addNotification(Map<String, dynamic> data, String key);

  /// 🔹 Delete specific notification
  Future<SuccessModel> deleteNotification(Map<String, dynamic> data, String key);

  /// 🔹 Update existing notification
  Future<SuccessModel> updateNotification(Map<String, dynamic> data, String key);
}
