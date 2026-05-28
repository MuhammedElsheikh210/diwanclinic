import 'package:firebase_database/firebase_database.dart';
import '../../../../../../index/index_main.dart';

/// Queue Snapshot Manager
///
/// Saves a lightweight snapshot of the active queue whenever a significant
/// event occurs. Useful for:
///   - Debugging position complaints
///   - Audit trail (who was where and when)
///   - Analytics (wait times, missed rates …)
///
/// Firebase path:
///   doctors/{doctorUid}/queue_snapshots/{date}/{timestampMs}/
///     triggeredBy : String  (QueueChangeReason.systemLabel)
///     reservations: [ { key, orderNum, orderReserved, status, patientName,
///                        priorityLevel, checkedInAt, missedReturnedAt } ]
///
/// Snapshots are append-only — never overwritten or deleted by the app.
class ReservationSnapshotManager {
  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  /// Save a snapshot for ALL active reservations (approved + checkedIn).
  ///
  /// Call this after any of:
  ///   - priority change
  ///   - missed / missed_return
  ///   - emergency insertion
  ///   - shift start / end
  Future<void> saveSnapshot({
    required String doctorUid,
    required String appointmentDate,
    required List<ReservationModel> allReservations,
    required QueueChangeReason triggeredBy,
  }) async {
    final active = allReservations
        .where(
          (r) =>
              r.status == ReservationStatus.approved.value ||
              r.status == ReservationStatus.checkedIn.value ||
              r.status == ReservationStatus.inProgress.value,
        )
        .toList();

    if (active.isEmpty) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final path =
        'doctors/$doctorUid/queue_snapshots/$appointmentDate/$now';

    final snapshotData = {
      'triggeredBy': triggeredBy.systemLabel,
      'createdAt': now,
      'reservations': active
          .asMap()
          .entries
          .map(
            (e) => {
              'position': e.key + 1,
              'key': e.value.key,
              'orderNum': e.value.orderNum,
              'orderReserved': e.value.orderReserved,
              'status': e.value.status,
              'patientName': e.value.patientName,
              'priorityLevel': e.value.priorityLevel ?? 0,
              'checkedInAt': e.value.checkedInAt,
              'missedReturnedAt': e.value.missedReturnedAt,
            },
          )
          .toList(),
    };

    try {
      await FirebaseDatabase.instance.ref(path).set(snapshotData);
    } catch (e, stack) {
      debugPrintStack(stackTrace: stack);
    }
  }

  // -------------------------------------------------------------------------
  // Convenience: read last N snapshots (for debugging UI)
  // -------------------------------------------------------------------------

  /// Returns the [limit] most-recent snapshots for a given day.
  Future<List<Map<String, dynamic>>> getRecentSnapshots({
    required String doctorUid,
    required String appointmentDate,
    int limit = 10,
  }) async {
    final path = 'doctors/$doctorUid/queue_snapshots/$appointmentDate';

    try {
      final snapshot = await FirebaseDatabase.instance
          .ref(path)
          .orderByKey()
          .limitToLast(limit)
          .get();

      if (!snapshot.exists) return [];

      final map = Map<String, dynamic>.from(snapshot.value as Map);
      return map.values
          .map((v) => Map<String, dynamic>.from(v as Map))
          .toList()
          .reversed
          .toList(); // newest first
    } catch (e, stack) {
      debugPrintStack(stackTrace: stack);
      return [];
    }
  }
}
