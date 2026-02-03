import 'package:intl/intl.dart';
import '../../../../../index/index_main.dart';

class ReservationNotificationService {
  /// 🔥 Notify all today's active clients (new logic using SQLite)
  Future<void> notifyAllActiveClients({
    required String title,
    required String body,
  }) async {
    try {
      Loader.show();

      final notificationManager = NotificationManager();
      await notificationManager.init();

      final today = DateFormat('dd/MM/yyyy').format(DateTime.now());

      // 🔥 Fetch today's reservations from LOCAL SQLite
      List<ReservationModel> todayReservations = [];

      await ReservationService().getReservationsData(
        date: today,
        data: FirebaseFilter(),
        query: SQLiteQueryParams(
          is_filtered: true,
          where: "appointment_date_time = ?",
          whereArgs: [today],
        ),
        voidCallBack: (list) {
          todayReservations = list.whereType<ReservationModel>().toList();
        },
      );

      if (todayReservations.isEmpty) {
        Loader.dismiss();
        Loader.showError("لا توجد حجوزات اليوم.");
        return;
      }

      // 🔥 filter only pending + approved + in_progress
      todayReservations = todayReservations.where((r) {
        return r.status == ReservationStatus.pending.value ||
            r.status == ReservationStatus.approved.value ||
            r.status == ReservationStatus.inProgress.value;
      }).toList();

      if (todayReservations.isEmpty) {
        Loader.dismiss();
        Loader.showError("لا توجد حالات مطابقة لإرسال الإشعار.");
        return;
      }

      // 🔥 Collect tokens
      List<String> tokens = [];

      for (final r in todayReservations) {
        final clientKey = r.patientKey;
        if (clientKey == null) continue;

        await AuthenticationService().getClientsLocalData(
          query: SQLiteQueryParams(
            is_filtered: true,
            where: "key = ?",
            whereArgs: [clientKey],
          ),
          voidCallBack: (list) {
            if (list.isNotEmpty) {
              final LocalUser? u = list.first;
              final token = u?.fcmToken;

              if (token != null && token.isNotEmpty) {
                tokens.add(token);
              }
            }
          },
        );
      }

      if (tokens.isEmpty) {
        Loader.dismiss();
        Loader.showError("لا يوجد عملاء لديهم FCM Token.");
        return;
      }

      // 🔥 Send push notification
      await notificationManager.sendToMultipleDevices(
        tokens: tokens,
        title: title,
        body: body,
      );

      Loader.dismiss();
      Loader.showSuccess("تم إرسال الإشعار إلى ${tokens.length} عميل.");
    } catch (e) {
      Loader.dismiss();
      Loader.showError("فشل في الإرسال: $e");
    }
  }
}
