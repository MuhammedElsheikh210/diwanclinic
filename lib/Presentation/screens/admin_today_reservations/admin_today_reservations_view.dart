import '../../../index/index_main.dart';

class AdminTodayReservationsView extends StatelessWidget {
  const AdminTodayReservationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdminTodayReservationsViewModel>(
      init: AdminTodayReservationsViewModel(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.background_neutral_25,
          appBar: _buildAppBar(context, controller),
          body: Column(
            children: [
              _buildDoctorDropdown(context, controller),
              if (controller.selectedDoctor != null) ...[
                _buildStatsRow(context, controller),
              ],
              Expanded(child: _buildBody(context, controller)),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // App Bar
  // ============================================================

  AppBar _buildAppBar(
    BuildContext context,
    AdminTodayReservationsViewModel controller,
  ) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0.8,
      centerTitle: true,
      title: Column(
        children: [
          Text(
            'حجوزات اليوم',
            style: context.typography.lgBold.copyWith(
              color: AppColors.textDisplay,
              fontSize: 18,
            ),
          ),
          Text(
            controller.todayLabel,
            style: context.typography.smRegular.copyWith(
              color: AppColors.textSecondaryParagraph,
              fontSize: 11,
            ),
          ),
        ],
      ),
      iconTheme: const IconThemeData(color: AppColors.textDisplay),
      actions: [
        if (controller.selectedDoctor != null)
          IconButton(
            onPressed: controller.reloadCurrent,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'تحديث',
          ),
      ],
    );
  }

  // ============================================================
  // Doctor Dropdown
  // ============================================================

  Widget _buildDoctorDropdown(
    BuildContext context,
    AdminTodayReservationsViewModel controller,
  ) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اختر الطبيب',
            style: context.typography.smMedium.copyWith(
              color: AppColors.textSecondaryParagraph,
            ),
          ),
          SizedBox(height: 8.h),
          controller.isLoadingDoctors
              ? Container(
                  height: 52.h,
                  decoration: BoxDecoration(
                    color: AppColors.background_neutral_100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  decoration: BoxDecoration(
                    color: AppColors.background_neutral_100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: controller.selectedDoctor != null
                          ? AppColors.primary.withValues(alpha: 0.4)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<LocalUser>(
                      isExpanded: true,
                      hint: Text(
                        'اختر دكتور...',
                        style: context.typography.mdRegular.copyWith(
                          color: AppColors.field_text_placeholder,
                        ),
                      ),
                      value: controller.selectedDoctor,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primary,
                      ),
                      style: context.typography.mdMedium.copyWith(
                        color: AppColors.textDisplay,
                      ),
                      items: controller.doctors.map((doctor) {
                        return DropdownMenuItem<LocalUser>(
                          value: doctor,
                          child: Text(
                            'د. ${doctor.name ?? ""}',
                            style: context.typography.mdMedium.copyWith(
                              color: AppColors.textDisplay,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: controller.selectDoctor,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  // ============================================================
  // Stats Row
  // ============================================================

  Widget _buildStatsRow(
    BuildContext context,
    AdminTodayReservationsViewModel controller,
  ) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 14.h),
      child: Row(
        children: [
          _statCard(
            context,
            label: 'الإجمالي',
            value: controller.reservations.length,
            color: AppColors.primary,
            icon: Icons.calendar_month_rounded,
          ),
          SizedBox(width: 8.w),
          _statCard(
            context,
            label: 'تم الكشف',
            value: controller.completedCount,
            color: const Color(0xFF10B981),
            icon: Icons.check_circle_rounded,
          ),
          SizedBox(width: 8.w),
          _statCard(
            context,
            label: 'في الانتظار',
            value: controller.pendingCount + controller.inProgressCount,
            color: Colors.orange,
            icon: Icons.hourglass_empty_rounded,
          ),
          SizedBox(width: 8.w),
          _statCard(
            context,
            label: 'ملغي',
            value: controller.cancelledCount,
            color: AppColors.errorForeground,
            icon: Icons.cancel_rounded,
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    BuildContext context, {
    required String label,
    required int value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            SizedBox(height: 4.h),
            Text(
              '$value',
              style: context.typography.lgBold.copyWith(color: color),
            ),
            Text(
              label,
              style: context.typography.xsRegular.copyWith(
                color: AppColors.textSecondaryParagraph,
                fontSize: 10.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Body
  // ============================================================

  Widget _buildBody(
    BuildContext context,
    AdminTodayReservationsViewModel controller,
  ) {
    if (controller.selectedDoctor == null) {
      return _emptyState(
        context,
        icon: Icons.person_search_rounded,
        message: 'اختر دكتور لعرض حجوزات اليوم',
      );
    }

    if (controller.isLoadingReservations) {
      return const ShimmerLoader();
    }

    if (controller.reservations.isEmpty) {
      return _emptyState(
        context,
        icon: Icons.event_busy_rounded,
        message: 'لا يوجد حجوزات اليوم لهذا الطبيب',
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: controller.reservations.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        return _ReservationAdminCard(
          reservation: controller.reservations[index],
        );
      },
    );
  }

  Widget _emptyState(
    BuildContext context, {
    required IconData icon,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.grayMedium.withValues(alpha: 0.4)),
          SizedBox(height: 16.h),
          Text(
            message,
            style: context.typography.mdMedium.copyWith(
              color: AppColors.textSecondaryParagraph,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RESERVATION CARD (Admin Read-only)
// ─────────────────────────────────────────────────────────────────────────────

class _ReservationAdminCard extends StatelessWidget {
  final ReservationModel reservation;

  const _ReservationAdminCard({required this.reservation});

  ReservationStatus get _status =>
      ReservationStatusExt.fromValue(reservation.status ?? '');

  @override
  Widget build(BuildContext context) {
    final status = _status;
    final statusColor = status.color;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──────────────────────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.07),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(13.r),
                topRight: Radius.circular(13.r),
              ),
              border: Border(
                bottom: BorderSide(
                  color: statusColor.withValues(alpha: 0.14),
                ),
              ),
            ),
            child: Row(
              children: [
                // Queue number
                if (reservation.orderNum != null) ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      '#${reservation.orderNum}',
                      style: context.typography.smSemiBold.copyWith(
                        color: statusColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                ],
                // Patient name
                Expanded(
                  child: Text(
                    reservation.patientName ?? 'غير معروف',
                    style: context.typography.mdBold.copyWith(
                      color: AppColors.textDisplay,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Status badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        status.label,
                        style: context.typography.xsMedium.copyWith(
                          color: statusColor,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ── Body ────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow(
                        context,
                        icon: Icons.phone_rounded,
                        value: reservation.patientPhone ?? 'لا يوجد',
                        color: AppColors.primary,
                      ),
                      if (reservation.reservationType != null) ...[
                        SizedBox(height: 6.h),
                        _infoRow(
                          context,
                          icon: Icons.medical_information_rounded,
                          value: reservation.reservationType!,
                          color: Colors.blueGrey,
                        ),
                      ],
                    ],
                  ),
                ),
                if (reservation.paidAmount != null &&
                    reservation.paidAmount!.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: const Color(0xFF10B981).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'المدفوع',
                          style: context.typography.xsRegular.copyWith(
                            color: AppColors.textSecondaryParagraph,
                          ),
                        ),
                        Text(
                          '${reservation.paidAmount} ج.م',
                          style: context.typography.smSemiBold.copyWith(
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    BuildContext context, {
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            value,
            style: context.typography.smMedium.copyWith(
              color: AppColors.textDisplay,
            ),
          ),
        ),
      ],
    );
  }
}
