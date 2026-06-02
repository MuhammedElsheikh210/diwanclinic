import 'package:firebase_database/firebase_database.dart';
import '../../../../../../index/index_main.dart';

/// Smart Clinic Flow Queue Manager
///
/// Newborn rule (level == 3):
///   Newborns are NOT hard priority. They are inserted at configurable positions
///   in the sorted queue. The gap is read from [newbornSlotGap] (default 2).
///   1st newborn → after [gap] regular cases, 2nd → after gap×2+1, …
///   Formula (0-based index): insertAt = gap + newbornIndex × (gap + 1).
///   Multiple newborns are ordered among themselves by arrival time.
///
/// Sorting order for non-newborn patients:
///   1. Hard priority DESC         (level >= 4: urgent only — bypass window)
///   2. Inside window DESC         (orderNum within current doctor's window)
///   3. Checked-in (not missed-returned) DESC
///   4. Soft priority DESC         (level 1-2: VIP, elderly)
///   5. Reservation order ASC      (original booking number)
///   6. Effective arrival time ASC
///
/// Missed-Return logic:
///   A patient who was marked missed and then returned (missedReturnedAt != null)
///   re-enters the active queue within the same window, but WITHOUT the step-3
///   checked-in boost.
class ReservationQueueManager {
  static const int defaultWindowSize = 5;

  /// How many regular cases must come before a newborn.
  /// Defaults to 2 (positions 3, 6, 9 …).
  /// Set this from the selected clinic's [ClinicModel.effectiveNewbornSlotGap].
  int newbornSlotGap = 2;

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

    // Payment-blocked: approved status but waiting for payment review
    final awaitingPayment = all
        .where(
          (r) =>
              (r.status == ReservationStatus.approved.value ||
                  r.status == ReservationStatus.checkedIn.value) &&
              r.paymentStatus == 'pending_payment',
        )
        .toList();

    final paymentRejected = all
        .where(
          (r) =>
              (r.status == ReservationStatus.approved.value ||
                  r.status == ReservationStatus.checkedIn.value) &&
              r.paymentStatus == 'payment_rejected',
        )
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
      ...pending,           // 🔔 needs assistant action → always first
      ...inProgress,
      ...sortedActive,
      ...awaitingPayment,   // ⏳ waiting for assistant to review screenshot
      ...paymentRejected,   // ❌ rejected — patient must re-upload
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
              (r.status == ReservationStatus.approved.value ||
                  r.status == ReservationStatus.checkedIn.value) &&
              // Only enter queue when payment is either not required (null)
              // or has been explicitly approved.
              (r.paymentStatus == null ||
                  r.paymentStatus == 'payment_approved'),
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
    // Split newborns from everyone else
    final newborns = active.where((r) => r.priorityLevel == 3).toList();
    final others = active.where((r) => (r.priorityLevel ?? 0) != 3).toList();

    // Sort non-newborn patients using the standard rules
    others.sort((a, b) {
      // 1. Urgent hard priority (level >= 4) always first
      final aHard = a.isHardPriority ? 1 : 0;
      final bHard = b.isHardPriority ? 1 : 0;
      if (aHard != bHard) return bHard.compareTo(aHard);

      // 2. Inside active window
      final aWin = _isInWindow(a.orderNum, currentOrder) ? 1 : 0;
      final bWin = _isInWindow(b.orderNum, currentOrder) ? 1 : 0;
      if (aWin != bWin) return bWin.compareTo(aWin);

      // 3. Checked in — returned-from-missed do NOT get this boost
      final aCheck = (a.isCheckedIn && !a.isReturnedFromMissed) ? 1 : 0;
      final bCheck = (b.isCheckedIn && !b.isReturnedFromMissed) ? 1 : 0;
      if (aCheck != bCheck) return bCheck.compareTo(aCheck);

      // 4. Soft priority (1-2)
      final aSoft = a.priorityLevel ?? 0;
      final bSoft = b.priorityLevel ?? 0;
      if (aSoft != bSoft) return bSoft.compareTo(aSoft);

      // 5. Booking order
      final aOrder = a.orderNum ?? 9999;
      final bOrder = b.orderNum ?? 9999;
      if (aOrder != bOrder) return aOrder.compareTo(bOrder);

      // 6. Effective arrival time
      final aArrival = a.effectiveArrivalTime ?? double.maxFinite.toInt();
      final bArrival = b.effectiveArrivalTime ?? double.maxFinite.toInt();
      return aArrival.compareTo(bArrival);
    });

    // Sort newborns among themselves by arrival (first arrived → earlier slot)
    newborns.sort((a, b) {
      final aArr = a.effectiveArrivalTime ?? double.maxFinite.toInt();
      final bArr = b.effectiveArrivalTime ?? double.maxFinite.toInt();
      return aArr.compareTo(bArr);
    });

    // Insert each newborn at configurable positions (0-based):
    //   gap=2 → positions 2, 5, 8, 11, …  (after 2, 5, 8 regular cases)
    //   gap=3 → positions 3, 7, 11, 15, … (after 3, 7, 11 regular cases)
    //   formula: targetIdx = gap + i × (gap + 1)
    // NEVER past a patient who registered AFTER this newborn.
    final gap = newbornSlotGap;
    final result = List<ReservationModel>.from(others);
    for (int i = 0; i < newborns.length; i++) {
      final newbornOrderNum = newborns[i].orderNum ?? 9999;

      // First position in current result that belongs to a patient who
      // registered AFTER this newborn (orderNum > newborn's orderNum).
      int firstLaterIdx = result.indexWhere(
        (r) => (r.orderNum ?? 9999) > newbornOrderNum,
      );
      if (firstLaterIdx == -1) firstLaterIdx = result.length;

      // Ideal slot based on clinic's configured gap
      final targetIdx = gap + i * (gap + 1);

      // Never go past a later-registered patient — take the closer bound.
      final insertAt = targetIdx < firstLaterIdx ? targetIdx : firstLaterIdx;

      result.insert(insertAt, newborns[i]);
    }

    return result;
  }
}
