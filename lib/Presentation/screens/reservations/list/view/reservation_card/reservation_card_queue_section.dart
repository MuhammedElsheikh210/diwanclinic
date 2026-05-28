import '../../../../../../index/index_main.dart';

/// Header queue info — shows رقم الحجز + قبله كام in ONE row.
///
/// [ahead] is the 0-indexed position computed from [orderReserved]
/// (set by buildFinalList), so it stays stable after check-in.
///
/// Visibility:
///   • approved   → رقم الحجز  +  قدامك / دورك
///   • checkedIn  → رقم الحجز  +  قدامك / دورك  (same — never hides)
///   • inProgress → hidden (patient is being served)
///   • completed / cancelled → hidden
class ReservationCardQueueSection extends StatelessWidget {
  final ReservationModel reservation;
  final ReservationNewStatus status;

  /// 0-indexed queue position derived from orderReserved.
  /// Pass -1 to hide the ahead chip.
  final int ahead;

  const ReservationCardQueueSection({
    super.key,
    required this.reservation,
    required this.status,
    required this.ahead,
  });

  @override
  Widget build(BuildContext context) {
    // ── Hide for terminal / in-service statuses ──────────────────────────
    final s = reservation.status;
    if (s == ReservationStatus.completed.value ||
        s == ReservationStatus.inProgress.value ||
        s == ReservationStatus.cancelledByAssistant.value ||
        s == ReservationStatus.cancelledByUser.value ||
        s == ReservationStatus.cancelledByDoctor.value) {
      return const SizedBox.shrink();
    }

    final orderNum = reservation.orderNum;
    final showAhead = ahead >= 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── رقم الحجز ─────────────────────────────────────────────────
        _InfoChip(
          label: "رقم",
          value: "${orderNum ?? '-'}",
          valueColor: ColorMappingImpl().textDisplay,
          context: context,
        ),

        // ── Separator ─────────────────────────────────────────────────
        if (showAhead) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              width: 1,
              height: 18,
              color: ColorMappingImpl().borderNeutralPrimary,
            ),
          ),

          // ── قبله كام ──────────────────────────────────────────────
          if (ahead == 0)
            Text(
              "دورك دلوقتي",
              style: context.typography.mdMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            _InfoChip(
              label: "قدامك",
              value: "$ahead",
              valueColor: ColorMappingImpl().textDisplay,
              context: context,
            ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private helper widget
// ─────────────────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final BuildContext context;

  const _InfoChip({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.context,
  });

  @override
  Widget build(BuildContext _) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          text: "$label :",
          textStyle: context.typography.mdMedium.copyWith(
            color: ColorMappingImpl().textSecondaryParagraph,
          ),
        ),
        const SizedBox(width: 4),
        AppText(
          text: value,
          textStyle: context.typography.lgBold.copyWith(color: valueColor),
        ),
      ],
    );
  }
}
