import 'package:diwanclinic/Global/managers/location_manager.dart';
import 'package:diwanclinic/Presentation/screens/assistant_chat/assistant_chat_detail_view.dart';
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

    final hasDate = reservation.appointmentDateTime?.isNotEmpty == true;
    final isInQueue =
        status == ReservationStatus.approved ||
        status == ReservationStatus.checkedIn ||
        status == ReservationStatus.inProgress;
    final doctorName = reservation.doctorName ?? "غير معروف";
    final announcement = controller.getAnnouncementFor(reservation.doctorUid);

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
                      padding: EdgeInsets.fromLTRB(14, 14, 14, isHome ? 14 : 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── STATUS + RESERVATION NUMBER ROW ──
                          Row(
                            children: [
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
                              Text(
                                "#${reservation.orderNum ?? '-'}",
                                style: context.typography.mdMedium.copyWith(
                                  color: AppColors.textSecondaryParagraph,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          // ── DOCTOR NAME + MAP BUTTON ──────────
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
                                    if (reservation.reservationType?.isNotEmpty == true) ...[
                                      const SizedBox(height: 3),
                                      Text(
                                        reservation.reservationType!,
                                        style: context.typography.mdRegular.copyWith(
                                          color: AppColors.textSecondaryParagraph,
                                        ),
                                      ),
                                    ],
                                    if ((reservation.patientCode ?? '').isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 9,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(alpha: 0.10),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: statusColor.withValues(alpha: 0.25),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.tag_rounded,
                                              size: 12,
                                              color: statusColor,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              "كود: ${reservation.patientCode}",
                                              style: context.typography.smMedium
                                                  .copyWith(color: statusColor),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (reservation.clinicLatitude != null ||
                                  reservation.clinicAddress?.isNotEmpty == true)
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: _MapButton(reservation: reservation),
                                ),
                            ],
                          ),

                          // ── QUEUE CHIP (when in queue) ─────────
                          if (isInQueue) ...[
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: statusColor.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.people_outline_rounded,
                                    size: 14,
                                    color: statusColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "الدور",
                                    style: context.typography.mdRegular.copyWith(
                                      color: statusColor,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    aheadCount > 0
                                        ? "قدامك $aheadCount"
                                        : "دورك الآن 🎉",
                                    style: context.typography.mdBold.copyWith(
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // ── DATE CHIP ─────────────────────────
                          if (hasDate) ...[
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.grayLight.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
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
                                    style: context.typography.mdRegular.copyWith(
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
                          ],

                          // ── PENDING HINT ──────────────────────
                          if (reservation.status == ReservationStatus.pending.value) ...[
                            const SizedBox(height: 8),
                            _PendingHint(),
                          ],

                          // ── DOCTOR ANNOUNCEMENT BANNER ────────
                          if (announcement != null && announcement.isActive == true) ...[
                            const SizedBox(height: 10),
                            _AnnouncementBanner(announcement: announcement),
                          ],

                          // ── CHAT BUTTON (home only) ───────────
                          if (isHome && reservation.doctorUid != null) ...[
                            const SizedBox(height: 10),
                            _ChatBtn(reservation: reservation, fullWidth: true),
                          ],
                        ],
                      ),
                    ),

                    // ── DIVIDER + ACTIONS (list only) ─────────
                    if (!isHome) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        child: Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFEEF2F6),
                        ),
                      ),
                      _Actions(
                        reservation: reservation,
                        controller: controller,
                        status: status,
                        index: index,
                        isCancelled: isCancelled,
                        isCompleted: isCompleted,
                      ),
                    ],
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
// DOCTOR ANNOUNCEMENT BANNER
// ────────────────────────────────────────────────────────────────────────────
class _AnnouncementBanner extends StatelessWidget {
  final DoctorAnnouncementModel announcement;

  const _AnnouncementBanner({required this.announcement});

  @override
  Widget build(BuildContext context) {
    final type = announcement.announcementType;
    final color = type.color;
    final hasReason = announcement.reason?.isNotEmpty == true;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(type.icon, size: 15, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.arabicLabel,
                  style: context.typography.mdMedium.copyWith(color: color),
                ),
                if (hasReason) ...[
                  const SizedBox(height: 2),
                  Text(
                    announcement.reason!,
                    style: context.typography.smRegular.copyWith(
                      color: color.withValues(alpha: 0.80),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
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
        Icon(
          Icons.info_outline_rounded,
          size: 13,
          color: Colors.orange.shade700,
        ),
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
                    const Icon(
                      Icons.receipt_long_outlined,
                      size: 15,
                      color: AppColors.text_primary_paragraph,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "تفاصيل الحجز",
                      style: context.typography.smMedium.copyWith(
                        color: AppColors.text_primary_paragraph,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          if (reservation.doctorUid != null) _ChatBtn(reservation: reservation),

          const SizedBox(width: 10),

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
              Icon(
                Icons.warning_amber_rounded,
                size: 48.sp,
                color: AppColors.errorForeground,
              ),
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
                      child: Text(
                        "رجوع",
                        style: context.typography.mdMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
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
                      child: Text(
                        "تأكيد",
                        style: context.typography.mdMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
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
      builder: (_) => FeedbackSheet(reservation: reservation, controller: controller),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// REUSABLE WIDGETS
// ────────────────────────────────────────────────────────────────────────────

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

// ────────────────────────────────────────────────────────────────────────────
// CHAT BUTTON
// ────────────────────────────────────────────────────────────────────────────
class _ChatBtn extends StatelessWidget {
  final ReservationModel reservation;
  final bool fullWidth;

  const _ChatBtn({required this.reservation, this.fullWidth = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final session = Get.find<UserSession>();
        final patientId = session.user?.uid ?? "";
        final patientName = session.user?.name ?? "مريض";
        final patientFcmToken = session.user?.fcmToken;

        Get.to(
          () => AssistantChatDetailView(
            assistantId: reservation.doctorUid ?? "",
            assistantName: reservation.assistantName ?? "المساعدة",
            patientId: patientId,
            patientName: patientName,
            isAssistantSide: false,
            receiverFcmToken: reservation.assistantFcm ?? patientFcmToken,
          ),
          binding: Binding(),
        );
      },
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: fullWidth ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            const Icon(Icons.chat_rounded, size: 15, color: AppColors.primary),
            const SizedBox(width: 5),
            Text(
              "تواصل مع المساعدة",
              style: context.typography.smMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// MAP BUTTON
// ────────────────────────────────────────────────────────────────────────────
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
