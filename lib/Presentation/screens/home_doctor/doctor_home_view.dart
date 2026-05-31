import '../../../index/index_main.dart';

class DoctorHomeView extends StatelessWidget {
  const DoctorHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DoctorHomeViewModel>(
      init: DoctorHomeViewModel(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: CustomScrollView(
            slivers: [
              _DoctorHeader(controller: controller),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RevenueHeroCard(controller: controller),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 32.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionTitle(title: 'إحصائيات اليوم'),
                          SizedBox(height: 10.h),
                          _TodayStatsRow(controller: controller),
                          SizedBox(height: 22.h),
                          _SectionTitle(title: 'حالة اليوم'),
                          SizedBox(height: 10.h),
                          _AnnouncementSection(),
                          SizedBox(height: 22.h),
                          _PatientQueueSection(controller: controller),
                          _TodayAppointmentsSection(controller: controller),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════
// Header
// ══════════════════════════════════════════════════════
class _DoctorHeader extends StatelessWidget {
  final DoctorHomeViewModel controller;

  const _DoctorHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 130.h,
      collapsedHeight: kToolbarHeight,
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: AppColors.primary_light,
      surfaceTintColor: Colors.transparent,
      title: const Text(''),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          color: AppColors.primary_light,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
              child: Row(
                children: [
                  _Avatar(imageUrl: controller.profileImage),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'مرحباً،',
                          style: context.typography.xsRegular.copyWith(
                            color: AppColors.textSecondaryParagraph,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          controller.doctorName,
                          style: context.typography.lgBold.copyWith(
                            color: AppColors.textDisplay,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            if (controller.specializationName.isNotEmpty) ...[
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.10,
                                  ),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  controller.specializationName,
                                  style: context.typography.xsMedium.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                            ],
                            if (controller.rating > 0)
                              Row(
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    size: 13.sp,
                                    color: Colors.amber,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    controller.rating.toStringAsFixed(1),
                                    style: context.typography.xsMedium.copyWith(
                                      color: AppColors.textSecondaryParagraph,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    controller.todayFormatted,
                    style: context.typography.xsRegular.copyWith(
                      color: AppColors.textSecondaryParagraph,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: AppColors.dividerAndLines),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String imageUrl;

  const _Avatar({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56.w,
      height: 56.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.20)),
      ),
      child: ClipOval(
        child:
            imageUrl.isNotEmpty
                ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => _fallback(),
                )
                : _fallback(),
      ),
    );
  }

  Widget _fallback() =>
      const Icon(Icons.person_rounded, size: 28, color: AppColors.primary);
}

// ══════════════════════════════════════════════════════
// Revenue Hero — directly under app bar
// ══════════════════════════════════════════════════════
class _RevenueHeroCard extends StatelessWidget {
  final DoctorHomeViewModel controller;

  const _RevenueHeroCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.dividerAndLines)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إجمالي الدخل اليوم',
                  style: context.typography.xsRegular.copyWith(
                    color: AppColors.textSecondaryParagraph,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${controller.todayRevenue.toStringAsFixed(0)} ج.م',
                  style: context.typography.xlBold.copyWith(
                    color: AppColors.primary,
                    fontSize: 28.sp,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 36.h,
            color: AppColors.dividerAndLines,
            margin: EdgeInsets.symmetric(horizontal: 16.w),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${controller.completedCount}',
                style: context.typography.lgBold.copyWith(
                  color: AppColors.textDisplay,
                ),
              ),
              Text(
                'حجز مكتمل',
                style: context.typography.xsRegular.copyWith(
                  color: AppColors.textSecondaryParagraph,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// Section Title
// ══════════════════════════════════════════════════════
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: context.typography.mdBold.copyWith(color: AppColors.textDisplay),
    );
  }
}

// ══════════════════════════════════════════════════════
// Today Stats — 3 tiles
// ══════════════════════════════════════════════════════
class _TodayStatsRow extends StatelessWidget {
  final DoctorHomeViewModel controller;

  const _TodayStatsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            label: 'الإجمالي',
            value: controller.totalCount.toString(),
            icon: Icons.event_note_rounded,
            iconColor: AppColors.primary,
            bgColor: AppColors.white,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _StatTile(
            label: 'مكتمل',
            value: controller.completedCount.toString(),
            icon: Icons.check_circle_rounded,
            iconColor: const Color(0xFF10B981),
            bgColor: AppColors.white,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _StatTile(
            label: 'منتظر',
            value: controller.pendingCount.toString(),
            icon: Icons.hourglass_top_rounded,
            iconColor: const Color(0xFFF59E0B),
            bgColor: AppColors.white,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.dividerAndLines),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: iconColor, size: 18.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: context.typography.lgBold.copyWith(
              color: AppColors.textDisplay,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: context.typography.xsRegular.copyWith(
              color: AppColors.textSecondaryParagraph,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// Announcement
// ══════════════════════════════════════════════════════
class _AnnouncementSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<DoctorAnnouncementController>(
      init: DoctorAnnouncementController(),
      builder: (ctrl) {
        final ann = ctrl.activeAnnouncement;
        final hasAnn =
            ann != null &&
            ann.announcementType != DoctorAnnouncementType.arrived;

        final color = hasAnn ? ann.announcementType.color : AppColors.primary;
        final icon =
            hasAnn ? ann.announcementType.icon : Icons.campaign_outlined;
        final label =
            hasAnn ? ann.announcementType.arabicLabel : 'لا يوجد إعلان نشط';
        final sub = hasAnn ? (ann.reason ?? '') : 'اضغط لإعلان حالتك للمرضى';

        return _Card(
          child: Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: color, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: context.typography.smMedium.copyWith(
                        color: AppColors.textDisplay,
                      ),
                    ),
                    if (sub.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        sub,
                        style: context.typography.xsRegular.copyWith(
                          color: AppColors.textSecondaryParagraph,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const CreateAnnouncementBottomSheet(),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.20),
                    ),
                  ),
                  child: Text(
                    hasAnn ? 'تغيير' : 'إعلان',
                    style: context.typography.xsMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════
// Quick Actions — 2×2 grid
// ══════════════════════════════════════════════════════
class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mainCtrl = Get.find<MainPageViewModel>();

    final items = [
      _Action(
        label: 'الحجوزات',
        icon: Icons.calendar_month_rounded,
        color: AppColors.primary,
        onTap: () => mainCtrl.changeIndex(1),
      ),
      _Action(
        label: 'الدخل',
        icon: Icons.payments_rounded,
        color: AppColors.blueForeground,
        onTap: () => mainCtrl.changeIndex(2),
      ),
      _Action(
        label: 'التقييمات',
        icon: Icons.star_rounded,
        color: const Color(0xFFF59E0B),
        onTap: () => mainCtrl.changeIndex(3),
      ),
      _Action(
        label: 'الإعلانات',
        icon: Icons.campaign_rounded,
        color: const Color(0xFF7C3AED),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const CreateAnnouncementBottomSheet(),
          );
        },
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10.h,
      crossAxisSpacing: 10.w,
      childAspectRatio: 2.8,
      children: items.map((item) => _ActionCard(item: item)).toList(),
    );
  }
}

class _Action {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _Action({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _ActionCard extends StatelessWidget {
  final _Action item;

  const _ActionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.dividerAndLines),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(item.icon, color: item.color, size: 18.sp),
            ),
            SizedBox(width: 10.w),
            Text(
              item.label,
              style: context.typography.smMedium.copyWith(
                color: AppColors.textDisplay,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// Patient Queue
// ══════════════════════════════════════════════════════
class _PatientQueueSection extends StatelessWidget {
  final DoctorHomeViewModel controller;

  const _PatientQueueSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final hasCurrent = controller.currentPatient != null;
    final hasNext = controller.nextPatient != null;

    if (!hasCurrent && !hasNext) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 22.h),
        _SectionTitle(title: 'الطابور الحالي'),
        SizedBox(height: 10.h),
        if (hasCurrent)
          _PatientRow(reservation: controller.currentPatient!, isCurrent: true),
        if (hasCurrent && hasNext) SizedBox(height: 8.h),
        if (hasNext)
          _PatientRow(reservation: controller.nextPatient!, isCurrent: false),
      ],
    );
  }
}

class _PatientRow extends StatelessWidget {
  final ReservationModel reservation;
  final bool isCurrent;

  const _PatientRow({required this.reservation, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    final color =
        isCurrent ? const Color(0xFF7C3AED) : AppColors.blueForeground;
    final label = isCurrent ? 'في الكشف الآن' : 'التالي في الطابور';

    return _Card(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              isCurrent ? Icons.medical_services_rounded : Icons.queue_rounded,
              color: color,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.typography.xsMedium.copyWith(color: color),
                ),
                SizedBox(height: 2.h),
                Text(
                  reservation.patientName ?? 'مريض',
                  style: context.typography.smMedium.copyWith(
                    color: AppColors.textDisplay,
                  ),
                ),
                if (reservation.reservationType != null)
                  Text(
                    reservation.reservationType!,
                    style: context.typography.xsRegular.copyWith(
                      color: AppColors.textSecondaryParagraph,
                    ),
                  ),
              ],
            ),
          ),
          if (reservation.orderNum != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                '#${reservation.orderNum}',
                style: context.typography.xsMedium.copyWith(color: color),
              ),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// Today's Appointments list
// ══════════════════════════════════════════════════════
class _TodayAppointmentsSection extends StatelessWidget {
  final DoctorHomeViewModel controller;

  const _TodayAppointmentsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final list = controller.approvedList;
    if (list.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 22.h),
        Row(
          children: [
            _SectionTitle(title: 'حجوزات اليوم'),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                '${list.length}',
                style: context.typography.xsMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        ...list.map(
          (r) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: _AppointmentTile(reservation: r),
          ),
        ),
      ],
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  final ReservationModel reservation;

  const _AppointmentTile({required this.reservation});

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: Text(
                '#${reservation.orderNum ?? '-'}',
                style: context.typography.xsMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reservation.patientName ?? 'مريض',
                  style: context.typography.smMedium.copyWith(
                    color: AppColors.textDisplay,
                  ),
                ),
                if ((reservation.reservationType ?? '').isNotEmpty)
                  Text(
                    reservation.reservationType!,
                    style: context.typography.xsRegular.copyWith(
                      color: AppColors.textSecondaryParagraph,
                    ),
                  ),
              ],
            ),
          ),
          if ((reservation.paidAmount ?? '').isNotEmpty)
            Text(
              '${reservation.paidAmount} ج.م',
              style: context.typography.xsMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// Shared Card
// ══════════════════════════════════════════════════════
class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const _Card({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.dividerAndLines),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
