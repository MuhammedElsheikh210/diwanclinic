import '../../../index/index_main.dart';

class DoctorHomeView extends StatelessWidget {
  const DoctorHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DoctorHomeViewModel>(
      init: DoctorHomeViewModel(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.white,
          body: CustomScrollView(
            slivers: [
              _DoctorHeader(controller: controller),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AnnouncementSection(),
                      SizedBox(height: 16.h),
                      _TodayStatsRow(controller: controller),
                      SizedBox(height: 16.h),
                      _RevenueCard(controller: controller),
                      SizedBox(height: 16.h),
                      _PatientQueueSection(controller: controller),
                    ],
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
// 🔵 Header — calm light card
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
      // ── Collapsed bar: just the page title ──
      title: Text(
        '',
        style: context.typography.mdBold.copyWith(color: AppColors.primary),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          color: AppColors.primary_light,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
              child: Row(
                children: [
                  // Avatar
                  _Avatar(imageUrl: controller.profileImage),

                  SizedBox(width: 14.w),

                  // Name + spec + date
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

                  // Date chip
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
// 🔵 Announcement Banner
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
        final label = hasAnn ? ann.announcementType.arabicLabel : 'حالة اليوم';
        final sub = hasAnn ? (ann.reason ?? '') : 'اضغط لإعلان حالتك للمرضى';

        return _Card(
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
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
// 🔵 Today's Stats — 3 small cards
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
            bgColor: AppColors.primary_light,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _StatTile(
            label: 'مكتمل',
            value: controller.completedCount.toString(),
            icon: Icons.check_circle_rounded,
            iconColor: const Color(0xFF10B981),
            bgColor: const Color(0xFFECFDF5),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _StatTile(
            label: 'منتظر',
            value: controller.pendingCount.toString(),
            icon: Icons.hourglass_top_rounded,
            iconColor: const Color(0xFFF59E0B),
            bgColor: const Color(0xFFFFFBEB),
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
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22.sp),
          SizedBox(height: 6.h),
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
// 🔵 Revenue Card — light, not heavy
// ══════════════════════════════════════════════════════
class _RevenueCard extends StatelessWidget {
  final DoctorHomeViewModel controller;

  const _RevenueCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.payments_rounded,
              color: AppColors.primary,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الدخل اليومي',
                  style: context.typography.xsRegular.copyWith(
                    color: AppColors.textSecondaryParagraph,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${controller.todayRevenue.toStringAsFixed(0)} ج.م',
                  style: context.typography.lgBold.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
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
// 🔵 Patient Queue
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
        Text(
          'الطابور الحالي',
          style: context.typography.smMedium.copyWith(
            color: AppColors.textDisplay,
          ),
        ),
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
// 🔵 Quick Actions — no section title
// ══════════════════════════════════════════════════════
class _QuickActionsRow extends StatelessWidget {
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

    return Row(
      children:
          items.map((item) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: _ActionButton(item: item),
              ),
            );
          }).toList(),
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

class _ActionButton extends StatelessWidget {
  final _Action item;

  const _ActionButton({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Column(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(15.r),
              border: Border.all(color: item.color.withValues(alpha: 0.18)),
            ),
            child: Icon(item.icon, color: item.color, size: 23.sp),
          ),
          SizedBox(height: 6.h),
          Text(
            item.label,
            style: context.typography.xsMedium.copyWith(
              color: AppColors.textSecondaryParagraph,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// 🔵 Shared Card
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
