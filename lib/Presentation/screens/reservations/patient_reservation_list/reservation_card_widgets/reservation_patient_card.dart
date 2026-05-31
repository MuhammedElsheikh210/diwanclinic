import 'package:diwanclinic/Global/managers/location_manager.dart';
import 'package:diwanclinic/Presentation/screens/reservations/patient_reservation_list/reservation_card_widgets/card_details.dart';
import '../../../../../../index/index_main.dart';

class ReservationPatientCard extends StatelessWidget {
  final ReservationModel reservation;
  final ReservationPatientViewModel controller;
  final int index;
  final bool? from_home;

  const ReservationPatientCard({
    super.key,
    required this.reservation,
    required this.controller,
    required this.index,
    this.from_home,
  });

  @override
  Widget build(BuildContext context) {
    final status = ReservationStatusExt.fromValue(reservation.status ?? "");
    final aheadCount = controller.calculateAheadCount(reservation);
    final statusColor = status.color;
    final isCancelled = status.isCancelled;
    final isCompleted = status == ReservationStatus.completed;
    final isHome = from_home == true;

    // Home card — completely different layout
    if (isHome) {
      return _HomeCard(
        reservation: reservation,
        status: status,
        statusColor: statusColor,
        aheadCount: aheadCount,
      );
    }

    final hasDate = reservation.appointmentDateTime?.isNotEmpty == true;
    final isInQueue = status == ReservationStatus.approved ||
        status == ReservationStatus.checkedIn ||
        status == ReservationStatus.inProgress;
    final doctorName = reservation.doctorName ?? "غير معروف";

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEF2F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── LEFT ACCENT BAR ──────────────────────────────
              Container(width: 4, color: statusColor),

              // ── CARD BODY ────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── STATUS ROW ────────────────────────
                          Row(
                            children: [
                              Container(
                                width: 7, height: 7,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                status.label,
                                style: context.typography.mdMedium
                                    .copyWith(color: statusColor),
                              ),
                              const Spacer(),
                              if (isInQueue)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 9, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: statusColor.withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: Text(
                                    aheadCount > 0
                                        ? "قدامك $aheadCount"
                                        : "دورك الآن 🎉",
                                    style: context.typography.mdRegular
                                        .copyWith(color: statusColor),
                                  ),
                                )
                              else
                                Text(
                                  "#${reservation.orderNum ?? '-'}",
                                  style: context.typography.mdMedium.copyWith(
                                    color: AppColors.textSecondaryParagraph,
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          // ── DOCTOR NAME ───────────────────────
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "د. $doctorName",
                                      style: context.typography.lgBold.copyWith(
                                        color: AppColors.textDisplay,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (reservation.reservationType
                                            ?.isNotEmpty ==
                                        true) ...[
                                      const SizedBox(height: 3),
                                      Text(
                                        reservation.reservationType!,
                                        style:
                                            context.typography.mdRegular
                                                .copyWith(
                                          color:
                                              AppColors.textSecondaryParagraph,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              // Map button — small, unobtrusive
                              if (reservation.clinicLatitude != null ||
                                  reservation.clinicAddress?.isNotEmpty == true)
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: _MapButton(reservation: reservation),
                                ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // ── DATE CHIP (full width) ────────────
                          if (hasDate)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 9),
                              decoration: BoxDecoration(
                                color: AppColors.grayLight.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 14,
                                    color: AppColors.textSecondaryParagraph,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "موعد الكشف",
                                    style: context.typography.mdRegular
                                        .copyWith(
                                      color: AppColors.textSecondaryParagraph,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    reservation.appointmentDateTime!,
                                    style: context.typography.mdBold.copyWith(
                                      color: AppColors.textDisplay,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // ── PENDING HINT ──────────────────────
                          if (reservation.status ==
                              ReservationStatus.pending.value) ...[
                            const SizedBox(height: 8),
                            _PendingHint(),
                          ],
                        ],
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                      child: Divider(height: 1, thickness: 1,
                          color: Color(0xFFEEF2F6)),
                    ),

                    // ── ACTIONS ───────────────────────────────
                    _Actions(
                      reservation: reservation,
                      controller: controller,
                      status: status,
                      index: index,
                      isCancelled: isCancelled,
                      isCompleted: isCompleted,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// HOME CARD — clean unified card for the home horizontal scroll
// ────────────────────────────────────────────────────────────────────────────
class _HomeCard extends StatelessWidget {
  final ReservationModel reservation;
  final ReservationStatus status;
  final Color statusColor;
  final int aheadCount;

  const _HomeCard({
    required this.reservation,
    required this.status,
    required this.statusColor,
    required this.aheadCount,
  });

  @override
  Widget build(BuildContext context) {
    final doctorName = reservation.doctorName ?? "غير معروف";
    final hasDate = reservation.appointmentDateTime?.isNotEmpty == true;
    final isInQueue = status == ReservationStatus.approved ||
        status == ReservationStatus.checkedIn ||
        status == ReservationStatus.inProgress;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left accent bar
              Container(width: 4, color: statusColor),

              // Card content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── STATUS + QUEUE ROW ───────────────────
                      Row(
                        children: [
                          // Status dot + label
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            status.label,
                            style: context.typography.mdMedium.copyWith(
                              color: statusColor,
                            ),
                          ),
                          const Spacer(),
                          // Queue or order number
                          if (isInQueue)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: statusColor.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Text(
                                aheadCount > 0
                                    ? "قدامك $aheadCount"
                                    : "دورك الآن 🎉",
                                style: context.typography.mdMedium
                                    .copyWith(color: statusColor),
                              ),
                            )
                          else
                            Text(
                              "#${reservation.orderNum ?? '-'}",
                              style: context.typography.mdMedium.copyWith(
                                color: AppColors.textSecondaryParagraph,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ── DOCTOR NAME ──────────────────────────
                      Text(
                        "د. $doctorName",
                        style: context.typography.mdBold.copyWith(
                          color: AppColors.textDisplay,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (reservation.reservationType?.isNotEmpty == true) ...[
                        const SizedBox(height: 2),
                        Text(
                          reservation.reservationType!,
                          style: context.typography.mdRegular.copyWith(
                            color: AppColors.textSecondaryParagraph,
                          ),
                        ),
                      ],

                      // ── DATE ROW ─────────────────────────────
                      if (hasDate) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.grayLight.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined,
                                  size: 14,
                                  color: AppColors.textSecondaryParagraph),
                              const SizedBox(width: 6),
                              Text(
                                "موعد الكشف",
                                style: context.typography.mdRegular.copyWith(
                                  color: AppColors.textSecondaryParagraph,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                reservation.appointmentDateTime!,
                                style: context.typography.mdMedium.copyWith(
                                  color: AppColors.textDisplay,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// PENDING HINT
// ────────────────────────────────────────────────────────────────────────────
class _PendingHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.info_outline_rounded, size: 13, color: Colors.orange.shade700),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            "بانتظار موافقة المساعدة على الحجز",
            style: context.typography.mdRegular.copyWith(
              color: Colors.orange.shade700,
            ),
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// ACTION BUTTONS
// ────────────────────────────────────────────────────────────────────────────
class _Actions extends StatelessWidget {
  final ReservationModel reservation;
  final ReservationPatientViewModel controller;
  final ReservationStatus status;
  final int index;
  final bool isCancelled;
  final bool isCompleted;

  const _Actions({
    required this.reservation,
    required this.controller,
    required this.status,
    required this.index,
    required this.isCancelled,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Row(
        children: [
          // ── Details button — clearly a button ──────────────
          Expanded(
            child: GestureDetector(
              onTap: () => Get.to(
                () => ReservationPatientDetailsScreen(
                  reservation: reservation,
                  controller: controller,
                  index: index,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: 15,
                        color: AppColors.text_primary_paragraph),
                    const SizedBox(width: 5),
                    Text(
                      "تفاصيل الحجز",
                      style: context.typography.mdMedium.copyWith(
                        color: AppColors.text_primary_paragraph,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // ── Secondary action ───────────────────────────────
          if (isCompleted && reservation.hasFeedback != true)
            _GhostBtn(
              label: "تقييم الدكتور",
              icon: Icons.star_outline_rounded,
              color: const Color(0xFFF59E0B),
              onTap: () => _showFeedbackSheet(context),
            ),

          if (!isCancelled && !isCompleted)
            _GhostBtn(
              label: "إلغاء",
              icon: Icons.close_rounded,
              color: AppColors.errorForeground,
              onTap: () => _confirmCancel(context),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final confirmed = await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 48.sp, color: AppColors.errorForeground),
              SizedBox(height: 10.h),
              Text("تأكيد الإلغاء", style: context.typography.lgBold),
              SizedBox(height: 8.h),
              Text(
                "هل أنت متأكد أنك تريد إلغاء هذا الحجز؟",
                textAlign: TextAlign.center,
                style: context.typography.mdMedium.copyWith(height: 1.5),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                      child: Text("رجوع",
                          style: context.typography.mdMedium
                              .copyWith(color: AppColors.primary)),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.errorForeground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                      child: Text("تأكيد",
                          style: context.typography.mdMedium
                              .copyWith(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true) return;
    reservation.status = ReservationStatus.cancelledByUser.value;
    controller.updateReservation(reservation);
    Loader.showSuccess("تم إلغاء الحجز");
  }

  void _showFeedbackSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) =>
          FeedbackSheet(reservation: reservation, controller: controller),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// REUSABLE WIDGETS
// ────────────────────────────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  final ReservationStatus status;
  final Color color;

  const _StatusPill({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Text(
        status.label,
        style: context.typography.mdMedium.copyWith(color: color),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color borderColor;
  final Color textColor;

  const _Chip({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.borderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: context.typography.mdMedium.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}

class _GhostBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _GhostBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: context.typography.mdMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  final ReservationModel reservation;

  const _MapButton({required this.reservation});

  Future<void> _open() async {
    final lat = reservation.clinicLatitude;
    final lng = reservation.clinicLongitude;
    final address = reservation.clinicAddress;
    Uri uri;

    if (lat != null && lng != null) {
      final userLatLng = await LocationManager().getLatLng();
      if (userLatLng != null) {
        uri = Uri.parse(
          "https://www.google.com/maps/dir/?api=1"
              "&origin=${userLatLng['lat']},${userLatLng['lng']}"
              "&destination=$lat,$lng"
              "&travelmode=driving",
        );
      } else {
        uri = Uri.parse(
          "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
        );
      }
    } else if (address != null && address.isNotEmpty) {
      uri = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}",
      );
    } else {
      return;
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _open,
      child: const Icon(
        Icons.directions_outlined,
        size: 17,
        color: AppColors.primary,
      ),
    );
  }
}
