import 'package:firebase_database/firebase_database.dart';
import '../../../../../../index/index_main.dart';

/// QueueReason Engine — writes WHY a patient's position changed.
///
/// Firebase path per reservation:
///   doctors/{doctorUid}/reservations/{date}/{key}/queue_reason
///   doctors/{doctorUid}/reservations/{date}/{key}/queue_reason_at
///
/// Patient app reads these fields and shows [QueueChangeReason.patientMessage].
class ReservationQueueReasonManager {
  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  /// Write the reason for a single reservation's position change.
  Future<void> writeReason({
    required ReservationModel reservation,
    required QueueChangeReason reason,
  }) async {
    final path = _reservationPath(reservation);
    if (path == null) return;

    try {
      await FirebaseDatabase.instance.ref(path).update({
        'queue_reason': reason.systemLabel,
        'queue_reason_at': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e, stack) {
      debugPrintStack(stackTrace: stack);
    }
  }

  /// Write reasons for all reservations in the queue after a bulk re-sort.
  /// Used after emergency insertions or window shifts.
  Future<void> writeBulkReason({
    required List<ReservationModel> reservations,
    required QueueChangeReason reason,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    for (final reservation in reservations) {
      final path = _reservationPath(reservation);
      if (path == null) continue;

      try {
        await FirebaseDatabase.instance.ref(path).update({
          'queue_reason': reason.systemLabel,
          'queue_reason_at': now,
        });
      } catch (e, stack) {
        debugPrintStack(stackTrace: stack);
      }
    }
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  String? _reservationPath(ReservationModel r) {
    if (r.doctorUid == null || r.appointmentDateTime == null || r.key == null) {
      return null;
    }
    return 'doctors/${r.doctorUid}/reservations/${r.appointmentDateTime}/${r.key}';
  }
}
