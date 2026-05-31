import 'package:diwanclinic/Presentation/screens/patients/profile_history_all_reservations/patient_profile_view.dart';
import '../../../../../index/index_main.dart';

// ══════════════════════════════════════════════════════════════
// 🩺 Reservation Doctor Card — redesigned
// ══════════════════════════════════════════════════════════════
class ReservationDoctorCard extends StatelessWidget {
  final ReservationModel reservation;
  final ReservationDoctorViewModel controller;
  final int index;

  const ReservationDoctorCard({
    super.key,
    required this.reservation,
    required this.controller,
    required this.index,
  });

  ReservationStatus get _status =>
      ReservationStatusExt.fromValue(reservation.status ?? '');

  bool get _hasPrescription =>
      (reservation.prescriptionUrl1?.isNotEmpty == true) ||
      (reservation.prescriptionUrl2?.isNotEmpty == true);

  bool get _isCancelled => _status.isCancelled;
  bool get _isCompleted => _status == ReservationStatus.completed;
  bool get _isInProgress => _status == ReservationStatus.inProgress;

  Color get _accentColor {
    if (_isInProgress) return const Color(0xFF4F46E5);
    if (_isCompleted) return AppColors.grayMedium;
    if (_isCancelled) return const Color(0xFFEF4444);
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.dividerAndLines),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Left status bar ──────────────────────────
              Container(width: 4.w, color: _accentColor),

              // ── Card body ────────────────────────────────
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(14.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TopRow(
                        reservation: reservation,
                        status: _status,
                        accentColor: _accentColor,
                      ),
                      SizedBox(height: 10.h),
                      _MetaRow(reservation: reservation),
                      if (_hasPrescription) ...[
                        SizedBox(height: 10.h),
                        _PrescriptionThumbnails(reservation: reservation),
                      ],
                      SizedBox(height: 12.h),
                      const Divider(
                        height: 1,
                        color: AppColors.dividerAndLines,
                      ),
                      SizedBox(height: 10.h),
                      _ActionRow(
                        reservation: reservation,
                        status: _status,
                        accentColor: _accentColor,
                        controller: controller,
                      ),
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

// ── Top row: order# + name + status badge ─────────────────
class _TopRow extends StatelessWidget {
  final ReservationModel reservation;
  final ReservationStatus status;
  final Color accentColor;

  const _TopRow({
    required this.reservation,
    required this.status,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Order badge
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Center(
            child: Text(
              '#${reservation.orderNum ?? "-"}',
              style: context.typography.smMedium.copyWith(color: accentColor),
            ),
          ),
        ),

        SizedBox(width: 10.w),

        // Name + phone
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reservation.patientName ?? 'مريض',
                style: context.typography.mdBold.copyWith(
                  color: AppColors.textDisplay,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if ((reservation.patientPhone ?? '').isNotEmpty) ...[
                SizedBox(height: 2.h),
                Text(
                  reservation.patientPhone!,
                  style: context.typography.xsRegular.copyWith(
                    color: AppColors.textSecondaryParagraph,
                  ),
                ),
              ],
            ],
          ),
        ),

        SizedBox(width: 8.w),

        // Status pill
        _StatusPill(status: status, color: accentColor),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final ReservationStatus status;
  final Color color;

  const _StatusPill({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        status.label,
        style: context.typography.xsMedium.copyWith(color: color),
      ),
    );
  }
}

// ── Meta row: type + payment + transfer image ─────────────
class _MetaRow extends StatelessWidget {
  final ReservationModel reservation;

  const _MetaRow({required this.reservation});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 6.h,
      children: [
        if ((reservation.reservationType ?? '').isNotEmpty)
          _Chip(
            label: reservation.reservationType!,
            icon: Icons.calendar_month_rounded,
            color: AppColors.textSecondaryParagraph,
          ),
        if (reservation.paymentMethod != null)
          _Chip(
            label: _paymentLabel(reservation.paymentMethod!),
            icon: Icons.payments_rounded,
            color: _paymentColor(reservation.paymentMethod!),
          ),
        if (reservation.transferImage != null)
          GestureDetector(
            onTap: () {
              Get.to(
                () => FullScreenGalleryView(
                  imageUrls: [reservation.transferImage!],
                  initialIndex: 0,
                ),
              );
            },
            child: const _Chip(
              label: 'إيصال دفع',
              icon: Icons.image_rounded,
              color: Color(0xFF0EA5E9),
            ),
          ),
      ],
    );
  }

  String _paymentLabel(String method) {
    return switch (method) {
      'instapay' => 'InstaPay',
      'wallet' => 'محفظة',
      _ => 'كاش',
    };
  }

  Color _paymentColor(String method) {
    return switch (method) {
      'instapay' => Colors.green.shade700,
      'wallet' => Colors.blue.shade700,
      _ => Colors.orange.shade700,
    };
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _Chip({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: context.typography.xsRegular.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

// ── Prescription thumbnails ────────────────────────────────
class _PrescriptionThumbnails extends StatelessWidget {
  final ReservationModel reservation;

  const _PrescriptionThumbnails({required this.reservation});

  @override
  Widget build(BuildContext context) {
    final images = [
      if (reservation.prescriptionUrl1?.isNotEmpty == true)
        reservation.prescriptionUrl1!,
      if (reservation.prescriptionUrl2?.isNotEmpty == true)
        reservation.prescriptionUrl2!,
    ];

    return SizedBox(
      height: 60.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, i) {
          return GestureDetector(
            onTap: () => Get.to(
              () => FullScreenGalleryView(imageUrls: images, initialIndex: i),
            ),
            child: Hero(
              tag: images[i],
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: CachedNetworkImage(
                  imageUrl: images[i],
                  width: 80.w,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Action row ────────────────────────────────────────────
class _ActionRow extends StatelessWidget {
  final ReservationModel reservation;
  final ReservationStatus status;
  final Color accentColor;
  final ReservationDoctorViewModel controller;

  const _ActionRow({
    required this.reservation,
    required this.status,
    required this.accentColor,
    required this.controller,
  });

  Future<void> _markCompleted() async {
    reservation.status = ReservationStatus.completed.value;
    controller.updateReservation(reservation);
    Loader.showSuccess('تم تحديث الحالة إلى ${ReservationStatus.completed.label}');
    await WhatsAppStatusMessageService.sendStatusWhatsAppMessage(
      reservation: reservation,
      clinic: controller.selectedClinic,
      newStatus: ReservationStatus.completed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Details button — always shown
        Expanded(
          child: _OutlineBtn(
            label: 'التفاصيل',
            icon: Icons.person_rounded,
            onTap: () => Get.to(
              () => PatientAllHistoryView(
                patientKey: reservation.patientUid ?? '',
              ),
              binding: Binding(),
            ),
          ),
        ),

        // inProgress → mark done
        if (status == ReservationStatus.inProgress) ...[
          SizedBox(width: 8.w),
          Expanded(
            child: _FilledBtn(
              label: 'تم الكشف',
              icon: Icons.check_rounded,
              color: const Color(0xFF10B981),
              onTap: _markCompleted,
            ),
          ),
        ],

        // pending → approve / cancel
        if (status == ReservationStatus.pending) ...[
          SizedBox(width: 8.w),
          _IconBtn(
            icon: Icons.check_rounded,
            color: const Color(0xFF10B981),
            onTap: () => _updateStatus(ReservationStatus.approved),
          ),
          SizedBox(width: 6.w),
          _IconBtn(
            icon: Icons.close_rounded,
            color: const Color(0xFFEF4444),
            onTap: () => _updateStatus(ReservationStatus.cancelledByAssistant),
          ),
        ],
      ],
    );
  }

  void _updateStatus(ReservationStatus s) {
    reservation.status = s.value;
    controller.updateReservation(reservation);
  }
}

class _OutlineBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _OutlineBtn({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38.h,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.dividerAndLines),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15.sp, color: AppColors.textSecondaryParagraph),
            SizedBox(width: 5.w),
            Text(
              label,
              style: context.typography.xsMedium.copyWith(
                color: AppColors.textSecondaryParagraph,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilledBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FilledBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38.h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15.sp, color: Colors.white),
            SizedBox(width: 5.w),
            Text(
              label,
              style: context.typography.xsMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38.w,
        height: 38.h,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Icon(icon, color: color, size: 18.sp),
      ),
    );
  }
}
