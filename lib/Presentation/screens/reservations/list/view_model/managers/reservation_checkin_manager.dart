import '../../../../../../index/index_main.dart';

/// Manages check-in and manual promote operations for the Smart Clinic Flow.
class ReservationCheckInManager {
  /// Mark patient as checked-in.
  /// Sets status → checkedIn and records checkedInAt timestamp.
  Future<void> checkIn({
    required ReservationModel reservation,
    required void Function(ReservationModel updated) onSuccess,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final updated = reservation.copyWith(
      status: ReservationStatus.checkedIn.value,
      checkedInAt: now,
      updatedAt: now,
    );

    await ReservationService().updateReservationData(
      reservation: updated,
      voidCallBack: (_) async {
        await PatientReservationService().updateReservationData(
          reservation: updated,
          voidCallBack: (_) {},
        );
        onSuccess(updated);
      },
    );
  }

  /// Return a missed patient back into the active queue.
  ///
  /// Rules:
  ///   - status  : missed → checkedIn
  ///   - missedReturnedAt = now   (used as effective arrival time in sort)
  ///   - checkedInAt stays unchanged  (historical record of first check-in)
  ///
  /// In the queue they land inside the same window (if orderNum qualifies)
  /// but WITHOUT the checked-in priority boost, so they sit below patients
  /// who never missed their turn.
  Future<void> returnFromMissed({
    required ReservationModel reservation,
    required void Function(ReservationModel updated) onSuccess,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final updated = reservation.copyWith(
      status: ReservationStatus.checkedIn.value,
      missedReturnedAt: now,
      updatedAt: now,
    );

    await ReservationService().updateReservationData(
      reservation: updated,
      voidCallBack: (_) async {
        await PatientReservationService().updateReservationData(
          reservation: updated,
          voidCallBack: (_) {},
        );
        onSuccess(updated);
      },
    );
  }

  /// Mark patient as missed (no-show).
  Future<void> markMissed({
    required ReservationModel reservation,
    required void Function() onSuccess,
  }) async {
    final updated = reservation.copyWith(
      status: ReservationStatus.missed.value,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await ReservationService().updateReservationData(
      reservation: updated,
      voidCallBack: (_) async {
        await PatientReservationService().updateReservationData(
          reservation: updated,
          voidCallBack: (_) {},
        );
        onSuccess();
      },
    );
  }

  /// Manual promote — boost a patient's priority so they move up the queue.
  /// Only allowed if patient has been waiting more than [minWaitMinutes].
  Future<void> manualPromote({
    required ReservationModel reservation,
    required int minWaitMinutes,
    required void Function(ReservationModel updated) onSuccess,
    required void Function(String reason) onDenied,
  }) async {
    final checkedIn = reservation.checkedInAt;
    if (checkedIn == null) {
      onDenied("المريض لم يسجل حضوره بعد");
      return;
    }

    final waitedMinutes =
        DateTime.now().difference(
              DateTime.fromMillisecondsSinceEpoch(checkedIn),
            ).inMinutes;

    if (waitedMinutes < minWaitMinutes) {
      final remaining = minWaitMinutes - waitedMinutes;
      onDenied("المريض انتظر $waitedMinutes دقيقة فقط، يجب الانتظار $remaining دقيقة أخرى");
      return;
    }

    // Promote by bumping priorityLevel to at least 2 (elderly equivalent)
    final boostedLevel =
        ((reservation.priorityLevel ?? 0) < 2) ? 2 : (reservation.priorityLevel ?? 0);

    final updated = reservation.copyWith(
      priorityLevel: boostedLevel,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await ReservationService().updateReservationData(
      reservation: updated,
      voidCallBack: (_) async {
        await PatientReservationService().updateReservationData(
          reservation: updated,
          voidCallBack: (_) {},
        );
        onSuccess(updated);
      },
    );
  }

  /// Returns how many minutes the patient has been waiting since check-in.
  int waitingMinutes(ReservationModel reservation) {
    if (reservation.checkedInAt == null) return 0;
    return DateTime.now()
        .difference(
          DateTime.fromMillisecondsSinceEpoch(reservation.checkedInAt!),
        )
        .inMinutes;
  }

  /// True if patient should trigger a waiting alert (waiting too long).
  bool shouldAlertWaiting(ReservationModel reservation, {int thresholdMinutes = 60}) {
    return waitingMinutes(reservation) >= thresholdMinutes;
  }
}
