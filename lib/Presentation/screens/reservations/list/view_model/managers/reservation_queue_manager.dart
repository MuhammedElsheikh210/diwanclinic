import '../../../../../../index/index_main.dart';

class ReservationQueueManager {
  // Calculate how many patients are ahead in queue
  int aheadInQueue({
    required List<ReservationModel?>? reservations,
    required ReservationModel target,
  }) {
    final queue =
        reservations
            ?.where(
              (e) =>
                  e?.status == ReservationStatus.pending.value ||
                  e?.status == ReservationStatus.approved.value,
            )
            .whereType<ReservationModel>()
            .toList() ??
        [];

    final index = queue.indexOf(target);

    return index <= 0 ? 0 : index;
  }

  // Reorder approved reservations and assign sequential order_reserved
  List<ReservationModel> reorderApprovedQueue(List<ReservationModel> approved) {
    approved.sort(
      (a, b) => (a.order_num ?? 9999).compareTo(b.order_num ?? 9999),
    );

    for (int i = 0; i < approved.length; i++) {
      approved[i] = approved[i].copyWith(order_reserved: i + 1);
    }

    return approved;
  }

  // Build final ordered reservation list for UI
  List<ReservationModel> buildFinalList(List<ReservationModel> all) {
    final pending = all
        .where((r) => r.status == ReservationStatus.pending.value)
        .toList();

    final inProgress = all
        .where((r) => r.status == ReservationStatus.inProgress.value)
        .toList();

    final approved = all
        .where((r) => r.status == ReservationStatus.approved.value)
        .toList();

    final completed = all
        .where((r) => r.status == ReservationStatus.completed.value)
        .toList();

    final cancelled = all
        .where(
          (r) =>
              r.status == ReservationStatus.cancelledByAssistant.value ||
              r.status == ReservationStatus.cancelledByUser.value ||
              r.status == ReservationStatus.cancelledByDoctor.value,
        )
        .toList();

    final queue = reorderApprovedQueue(approved);

    return [...pending, ...inProgress, ...queue, ...completed, ...cancelled];
  }

  Future<void> notifyApprovedQueueUpdate({
    required List<ReservationModel> allReservations,
  }) async {
    debugPrint("🔔 Starting notifyApprovedQueueUpdate...");
    debugPrint("📊 Total reservations: ${allReservations.length}");

    final approvedQueue = allReservations
        .where((r) => r.status == ReservationStatus.approved.value)
        .toList();

    debugPrint("✅ Approved reservations count: ${approvedQueue.length}");

    approvedQueue.sort(
      (a, b) => (a.order_num ?? 9999).compareTo(b.order_num ?? 9999),
    );

    debugPrint("🔢 Queue sorted by order_num");

    for (int i = 0; i < approvedQueue.length; i++) {
      final r = approvedQueue[i];

      debugPrint(
        "➡️ Processing reservation index: $i | "
        "order_num: ${r.order_num} | "
        "patientUid: ${r.patientUid}",
      );

      if (r.patientUid == null || r.fcmToken_patient == null) {
        debugPrint("⛔ Skipped - Missing UID or FCM token");
        continue;
      }

      final ahead = i;

      final body = ahead == 0
          ? "دورك الآن ✨ تفضل بالاستعداد للدخول"
          : "قبلك $ahead حالات، نرجو الاستعداد";

      try {
        await NotificationHandler().sendCustomNotification(
          toKey: r.patientUid!,
          toToken: r.fcmToken_patient!,
          title: "تحديث الدور",
          body: body,
          reservation: r,
          notificationType: "queue_update",
        );

        debugPrint("📨 Notification sent successfully to ${r.patientUid}");
      } catch (e, stackTrace) {
        debugPrint("❌ Error sending notification to ${r.patientUid}");
        debugPrint("Error: $e");
        debugPrint("StackTrace: $stackTrace");
      }
    }

    debugPrint("🏁 Finished notifyApprovedQueueUpdate");
  }
}
