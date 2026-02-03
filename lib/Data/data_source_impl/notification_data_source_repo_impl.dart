import 'package:diwanclinic/Data/data_source/notification_data_source_repo.dart';

import '../../index/index_main.dart';

class NotificationDataSourceRepoImpl extends NotificationDataSourceRepo {
  final ClientSourceRepo _clientSourceRepo;

  NotificationDataSourceRepoImpl(this._clientSourceRepo);

  // ─────────────────────────────────────────────
  // 📥 Get Notifications (Firebase only)
  // ─────────────────────────────────────────────
  @override
  Future<List<NotificationModel?>> getNotifications(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      ) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        "/${ApiConstatns.notifications}.json",
        params: data,
      );

      // ✅ Normalize Firebase response
      if (response is Map<String, dynamic>) {
        return response.entries.map((entry) {
          final json = Map<String, dynamic>.from(entry.value);
          return NotificationModel.fromJson(json);
        }).toList();
      }

      // ✅ Handle list-style response if Firebase returns array
      if (response is List) {
        return response.map((e) => NotificationModel.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      debugPrint("⚠️ getNotifications Error: $e");
      return [];
    }
  }

  // ─────────────────────────────────────────────
  // ➕ Add Notification
  // ─────────────────────────────────────────────
  @override
  Future<SuccessModel> addNotification(Map<String, dynamic> data, String key) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.PATCH,
        "/${ApiConstatns.notifications}/$key.json",
        params: data,
      );

      return SuccessModel.fromJson(response);
    } catch (e) {
      debugPrint("⚠️ addNotification Error: $e");
      return SuccessModel(message: "خطأ أثناء إضافة الإشعار");
    }
  }

  // ─────────────────────────────────────────────
  // 🗑️ Delete Notification
  // ─────────────────────────────────────────────
  @override
  Future<SuccessModel> deleteNotification(Map<String, dynamic> data, String key) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.DELETE,
        "/${ApiConstatns.notifications}/$key.json",
        params: data,
      );

      return SuccessModel.fromJson(response ?? {"message": "تم حذف الإشعار بنجاح"});
    } catch (e) {
      debugPrint("⚠️ deleteNotification Error: $e");
      return SuccessModel(message: "حدث خطأ أثناء حذف الإشعار");
    }
  }

  // ─────────────────────────────────────────────
  // 🔁 Update Notification
  // ─────────────────────────────────────────────
  @override
  Future<SuccessModel> updateNotification(Map<String, dynamic> data, String key) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.PATCH,
        "/${ApiConstatns.notifications}/$key.json",
        params: data,
      );

      return SuccessModel.fromJson(response);
    } catch (e) {
      debugPrint("⚠️ updateNotification Error: $e");
      return SuccessModel(message: "خطأ أثناء تحديث الإشعار");
    }
  }
}
