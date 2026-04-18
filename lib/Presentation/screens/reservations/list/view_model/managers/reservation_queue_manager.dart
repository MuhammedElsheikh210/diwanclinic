import 'package:firebase_database/firebase_database.dart';

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
    approved.sort((a, b) => (a.orderNum ?? 9999).compareTo(b.orderNum ?? 9999));

    for (int i = 0; i < approved.length; i++) {
      approved[i] = approved[i].copyWith(orderReserved: i + 1);
    }

    return approved;
  }

  // Build final ordered reservation list for UI
  List<ReservationModel> buildFinalList(List<ReservationModel> all) {
    final pending =
        all.where((r) => r.status == ReservationStatus.pending.value).toList();

    final inProgress =
        all
            .where((r) => r.status == ReservationStatus.inProgress.value)
            .toList();

    final approved =
        all.where((r) => r.status == ReservationStatus.approved.value).toList();

    final completed =
        all
            .where((r) => r.status == ReservationStatus.completed.value)
            .toList();

    final cancelled =
        all
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
    

    final approvedQueue =
        allReservations
            .where((r) => r.status == ReservationStatus.approved.value)
            .toList();

    

    /// ترتيب ثابت
    approvedQueue.sort(
      (a, b) => (a.orderNum ?? 9999).compareTo(b.orderNum ?? 9999),
    );

    for (int i = 0; i < approvedQueue.length; i++) {
      final r = approvedQueue[i];

      final oldOrder = r.orderReserved ?? -1;
      final newOrder = i + 1;
      final ahead = i;

      
      
      
      

      // /// 💣 ابعت بس لو فيه تغيير فعلي
      // if (oldOrder == newOrder) {
      //   debugPrint("⛔ SKIPPED (No change)");
      //   continue;
      // }

      final message =
          ahead == 0
              ? "دورك الآن ✨ تفضل بالاستعداد للدخول"
              : "قبلك $ahead حالات، نرجو الاستعداد";

      

      /// تحديث محلي علشان المقارنة المرة الجاية
      r.orderReserved = newOrder;

      /// Safety
      if (r.key == null ||
          r.doctorUid == null ||
          r.appointmentDateTime == null) {
        
        continue;
      }

      try {
        final path =
            "doctors/${r.doctorUid}"
            "/reservations/${r.appointmentDateTime}"
            "/${r.key}";

        final ref = FirebaseDatabase.instance.ref(path);

        final updateData = {
          /// 👇 ده اللي بيتغير فعلاً ويشغّل الفنكشن
          "queue_position": ahead,

          /// 👇 ضمان التريجر حتى لو القيمة نفسها
          "queue_trigger": DateTime.now().millisecondsSinceEpoch,
        };

        
        

        await ref.update(updateData);

        debugPrint("✅ UPDATED SUCCESS (Queue change pushed)");
      } catch (e, stack) {
        
        debugPrintStack(stackTrace: stack);
      }
    }

    
  }

  // Future<void> notifyApprovedQueueUpdate({
  //   required List<ReservationModel> allReservations,
  // }) async {
  //   
  //
  //   final approvedQueue = allReservations
  //       .where((r) => r.status == ReservationStatus.approved.value)
  //       .toList();
  //
  //   
  //
  //   approvedQueue.sort(
  //         (a, b) => (a.orderNum ?? 9999).compareTo(b.orderNum ?? 9999),
  //   );
  //
  //   for (int i = 0; i < approvedQueue.length; i++) {
  //     final r = approvedQueue[i];
  //
  //     final oldOrder = r.orderReserved ?? -1;
  //     final newOrder = i + 1;
  //     final ahead = i;
  //
  //     
  //     
  //     
  //     
  //
  //     // /// 💣 أهم شرط (Tracking)
  //     // if (oldOrder == newOrder) {
  //     //   debugPrint("⛔ SKIPPED (No change)");
  //     //   continue;
  //     // }
  //
  //     final message = ahead == 0
  //         ? "دورك الآن ✨ تفضل بالاستعداد للدخول"
  //         : "قبلك $ahead حالات، نرجو الاستعداد";
  //
  //     
  //
  //     /// ✅ update local (عشان المرة الجاية يقارن صح)
  //     r.orderReserved = newOrder;
  //
  //     // if (r.key == null || r.doctorUid == null) {
  //     //   
  //     //   continue;
  //     // }
  //
  //     try {
  //       final path =
  //           "doctors/${r.doctorUid}"
  //           "/reservations/${r.appointmentDateTime}"
  //           "/${r.key}";
  //
  //       final ref = FirebaseDatabase.instance.ref(path);
  //
  //       final updateData = {
  //         "queue_position": ahead,
  //         "queue_updated_at": ServerValue.timestamp,
  //
  //         /// 💣 مهم جدًا: يخلي function تعرف إنه update جديد
  //         "queue_trigger": DateTime.now().millisecondsSinceEpoch,
  //       };
  //
  //       
  //       
  //
  //       /// 🔥 ده اللي هيشغل Firebase Function
  //       await ref.update(updateData);
  //
  //       debugPrint("✅ UPDATED SUCCESS (Notification will be triggered)");
  //
  //     } catch (e, stack) {
  //       
  //       debugPrintStack(stackTrace: stack);
  //     }
  //   }
  //
  //   
  // }
}
