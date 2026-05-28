import 'package:firebase_database/firebase_database.dart';
import '../../../../../../index/index_main.dart';

/// Smart Clinic Flow Queue Manager
/// Sorting order:
///   1. Hard priority DESC         (level >= 3: newborn, urgent — bypass window)
///   2. Inside window DESC         (orderNum within current doctor's window)
///   3. Checked-in (not missed-returned) DESC  (physically present, first time)
///   4. Soft priority DESC         (level 1-2: VIP, elderly)
///   5. Effective arrival time ASC (missedReturnedAt if returned, else checkedInAt)
///   6. Reservation order ASC      (original booking number)
///
/// Missed-Return logic:
///   A patient who was marked missed and then returned (missedReturnedAt != null)
///   re-enters the active queue within the same window, but WITHOUT the step-3
///   checked-in boost. They sort after regular checked-in patients but before
///   anyone outside the window.
class ReservationQueueManager {
  static const int defaultWindowSize = 5;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Returns how many patients are ahead of [target] in the smart execution order.
  int aheadInQueue({
    required List<ReservationModel?>? reservations,
    required ReservationModel target,
  }) {
    final active = _extractActive(reservations ?? []);
    final currentOrder = _currentDoctorOrder(reservations ?? []);
    final sorted = _sortActive(active, currentOrder);
    final index = sorted.indexWhere((r) => r.key == target.key);
    return index <= 0 ? 0 : index;
  }

  /// Range-based estimation to avoid exact number promises.
  /// Returns e.g. "من 0 إلى 1" so emergency insertions don't feel like lies.
  String aheadRange({
    required List<ReservationModel?>? reservations,
    required ReservationModel target,
    int buffer = 1,
  }) {
    final ahead = aheadInQueue(reservations: reservations, target: target);
    if (ahead == 0) return "دورك قريب جداً";
    final max = ahead + buffer;
    return "من $ahead إلى $max";
  }

  /// Builds the final ordered list for UI display.
  List<ReservationModel> buildFinalList(List<ReservationModel> all) {
    final inProgress = all
        .where((r) => r.status == ReservationStatus.inProgress.value)
        .toList();

    final active = _extractActive(all);
    final currentOrder = _currentDoctorOrder(all);
    final sortedActive = _sortActive(active, currentOrder);

    // Assign execution order so notifications & UI show correct position
    for (int i = 0; i < sortedActive.length; i++) {
      sortedActive[i].orderReserved = i + 1;
    }

    final pending = all
        .where((r) => r.status == ReservationStatus.pending.value)
        .toList();

    final completed = all
        .where((r) => r.status == ReservationStatus.completed.value)
        .toList();

    final missed = all
        .where((r) => r.status == ReservationStatus.missed.value)
        .toList();

    final cancelledValues = {
      ReservationStatus.cancelledByUser.value,
      ReservationStatus.cancelledByAssistant.value,
      ReservationStatus.cancelledByDoctor.value,
    };
    final cancelled = all
        .where((r) => cancelledValues.contains(r.status))
        .toList();

    return [
      ...inProgress,
      ...sortedActive,
      ...pending,
      ...completed,
      ...missed,
      ...cancelled,
    ];
  }

  /// Push queue_position updates to Firebase so patient apps receive notifications.
  Future<void> notifyApprovedQueueUpdate({
    required List<ReservationModel> allReservations,
  }) async {
    final active = _extractActive(allReservations);
    final currentOrder = _currentDoctorOrder(allReservations);
    final sorted = _sortActive(active, currentOrder);

    for (int i = 0; i < sorted.length; i++) {
      final r = sorted[i];
      final ahead = i;

      r.orderReserved = i + 1;

      if (r.key == null || r.doctorUid == null || r.appointmentDateTime == null) {
        continue;
      }

      try {
        final path =
            "doctors/${r.doctorUid}"
            "/reservations/${r.appointmentDateTime}"
            "/${r.key}";

        await FirebaseDatabase.instance.ref(path).update({
          "queue_position": ahead,
          "queue_trigger": DateTime.now().millisecondsSinceEpoch,
        });
      } catch (e, stack) {
        debugPrintStack(stackTrace: stack);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  List<ReservationModel> _extractActive(List<ReservationModel?> all) {
    return all
        .whereType<ReservationModel>()
        .where(
          (r) =>
              r.status == ReservationStatus.approved.value ||
              r.status == ReservationStatus.checkedIn.value,
        )
        .toList();
  }

  /// The orderNum of the patient currently being seen (inProgress).
  /// Returns 0 if no one is in progress → all patients considered in window.
  int _currentDoctorOrder(List<ReservationModel?> all) {
    final inProg = all
        .whereType<ReservationModel>()
        .where((r) => r.status == ReservationStatus.inProgress.value)
        .toList();
    if (inProg.isEmpty) return 0;
    return inProg.first.orderNum ?? 0;
  }

  bool _isInWindow(int? orderNum, int currentOrder, [int size = defaultWindowSize]) {
    if (orderNum == null) return false;
    if (currentOrder == 0) return true; // no current patient → everyone eligible
    return orderNum >= currentOrder && orderNum <= currentOrder + size;
  }

  List<ReservationModel> _sortActive(
    List<ReservationModel> active,
    int currentOrder,
  ) {
    final list = List<ReservationModel>.from(active);

    list.sort((a, b) {
      // 1. Hard priority (level >= 3) always first
      final aHard = a.isHardPriority ? 1 : 0;
      final bHard = b.isHardPriority ? 1 : 0;
      if (aHard != bHard) return bHard.compareTo(aHard);

      // 2. Inside active window
      final aWin = _isInWindow(a.orderNum, currentOrder) ? 1 : 0;
      final bWin = _isInWindow(b.orderNum, currentOrder) ? 1 : 0;
      if (aWin != bWin) return bWin.compareTo(aWin);

      // 3. Checked in at clinic — returned-from-missed do NOT get this boost.
      //    They re-enter the window but sit below first-time checked-in patients.
      final aCheck = (a.isCheckedIn && !a.isReturnedFromMissed) ? 1 : 0;
      final bCheck = (b.isCheckedIn && !b.isReturnedFromMissed) ? 1 : 0;
      if (aCheck != bCheck) return bCheck.compareTo(aCheck);

      // 4. Soft priority (1-2)
      final aSoft = a.priorityLevel ?? 0;
      final bSoft = b.priorityLevel ?? 0;
      if (aSoft != bSoft) return bSoft.compareTo(aSoft);

      // 5. Original reservation order — booking sequence determines turn within
      //    the same tier. A patient with orderNum=4 should go before orderNum=7
      //    even if 7 checked in first (scenarios 3, 25).
      final aOrder = a.orderNum ?? 9999;
      final bOrder = b.orderNum ?? 9999;
      if (aOrder != bOrder) return aOrder.compareTo(bOrder);

      // 6. Effective arrival time (tiebreaker):
      //    • Returned-from-missed → missedReturnedAt
      //    • Normal              → checkedInAt
      final aArrival = a.effectiveArrivalTime ?? double.maxFinite.toInt();
      final bArrival = b.effectiveArrivalTime ?? double.maxFinite.toInt();
      return aArrival.compareTo(bArrival);
    });

    return list;
  }
}
