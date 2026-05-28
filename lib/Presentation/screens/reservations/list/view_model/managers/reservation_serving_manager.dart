import 'package:firebase_database/firebase_database.dart';
import '../../../../../../index/index_main.dart';

/// Manages the "who is currently being served" pointer in Firebase.
///
/// Firebase path:
///   doctors/{doctorUid}/active/{appointmentDate}/currentServingId
///
/// This is the SINGLE SOURCE OF TRUTH used by:
///   - Audio call screens
///   - Waiting-room display boards
///   - Patient notifications
///   - Window calculations
///
/// All readers listen to this node instead of scanning for status == inProgress.
class ReservationServingManager {
  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  /// Call when a reservation transitions to [inProgress].
  /// Writes the reservation key to the Firebase serving pointer.
  Future<void> setCurrentServing(ReservationModel reservation) async {
    final path = _servingPath(reservation);
    if (path == null) return;

    try {
      await FirebaseDatabase.instance.ref(path).set({
        'currentServingId': reservation.key,
        'patientName': reservation.patientName,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e, stack) {
      debugPrintStack(stackTrace: stack);
    }
  }

  /// Call when the current patient finishes (completed / missed / cancelled).
  /// Clears the Firebase serving pointer so no stale ID is left.
  Future<void> clearCurrentServing(ReservationModel reservation) async {
    final path = _servingPath(reservation);
    if (path == null) return;

    try {
      await FirebaseDatabase.instance.ref(path).set({
        'currentServingId': null,
        'patientName': null,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e, stack) {
      debugPrintStack(stackTrace: stack);
    }
  }

  /// Stream that other parts of the app can listen to
  /// for real-time updates of who is currently being served.
  Stream<String?> watchCurrentServingId({
    required String doctorUid,
    required String appointmentDate,
  }) {
    final path = _buildPath(doctorUid, appointmentDate);
    return FirebaseDatabase.instance
        .ref('$path/currentServingId')
        .onValue
        .map((event) => event.snapshot.value as String?);
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  String? _servingPath(ReservationModel reservation) {
    final doctorUid = reservation.doctorUid;
    final date = reservation.appointmentDateTime;
    if (doctorUid == null || date == null) return null;
    return _buildPath(doctorUid, date);
  }

  String _buildPath(String doctorUid, String appointmentDate) =>
      'doctors/$doctorUid/active/$appointmentDate';
}
