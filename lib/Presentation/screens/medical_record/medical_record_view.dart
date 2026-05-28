import '../../../index/index_main.dart';

// السجل الطبي يعرض فقط الأوردرات المكتملة/المسلّمة
const _kDoneStatuses = {'delivered', 'completed', 'order_confirmed'};

class MedicalRecordView extends StatelessWidget {
  const MedicalRecordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4FAF6),
        appBar: _appBar(context),
        body: GetBuilder<HomePatientController>(
          init: HomePatientController(),
          builder: (controller) {
            final records =
                controller.orders
                    .where((o) => _kDoneStatuses.contains(o.status))
                    .toList()
                  ..sort(
                    (a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0),
                  );

            if (controller.orders.isEmpty) {
              return const _EmptyState(hasOrders: false);
            }
            if (records.isEmpty) {
              return const _EmptyState(hasOrders: true);
            }

            return ListView.builder(
              padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 40.h),
              itemCount: records.length,
              itemBuilder:
                  (_, i) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: _RecordCard(order: records[i]),
                  ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    final t = context.typography;

    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 92.h,
      backgroundColor: const Color(0xffF8FAFC),
      surfaceTintColor: Colors.transparent,
      titleSpacing: 18.w,
      title: Row(
        children: [
          Container(
            width: 54.w,
            height: 54.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.r),
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: .78),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: .22),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.medical_services_rounded,
              color: Colors.white,
              size: 26.sp,
            ),
          ),

          SizedBox(width: 14.w),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: 'السجل الطبي',
                  textStyle: t.xlBold.copyWith(
                    color: AppColors.textDisplay,
                    fontSize: 24.sp,
                    height: 1,
                  ),
                ),

                SizedBox(height: 6.h),

                AppText(
                  text: 'كل الروشتات والأدوية محفوظة بأمان',
                  textStyle: t.smRegular.copyWith(
                    color: AppColors.textSecondaryParagraph,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.borderNeutralPrimary),
            ),
            child: Icon(
              Icons.history_rounded,
              color: AppColors.primary,
              size: 22.sp,
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(16.h),
        child: Container(
          height: 16.h,
          decoration: BoxDecoration(
            color: const Color(0xffF8FAFC),
            border: Border(
              bottom: BorderSide(
                color: AppColors.borderNeutralPrimary.withValues(alpha: .6),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RECORD CARD
// ─────────────────────────────────────────────────────────────────────────────

class _RecordCard extends StatelessWidget {
  final OrderModel order;

  const _RecordCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final t = context.typography;

    final img = _firstImage;

    final hasMeds = order.medicines != null && order.medicines!.isNotEmpty;

    final hasPrice = order.finalAmount != null && order.finalAmount! > 0;

    final cfg = _statusCfg(order.status ?? 'delivered');

    return GestureDetector(
      onTap: () {
        Get.to(() => MedicalRecordDetailsView(order: order));
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(
            color: AppColors.borderNeutralPrimary.withValues(alpha: .6),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .03),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // image
                _Thumb(url: img),

                SizedBox(width: 12.w),

                // info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: _formatDate(order.createdAt),
                        textStyle: t.mdBold.copyWith(
                          color: AppColors.textDisplay,
                          fontSize: 15.sp,
                        ),
                      ),

                      if (order.doctorName != null &&
                          order.doctorName!.isNotEmpty)
                        _TinyInfoRow(
                          icon: Icons.person_outline_rounded,
                          text: "د. ${order.doctorName}",
                          color: AppColors.primary,
                        ),

                      if (hasMeds) ...[
                        SizedBox(height: 5.h),

                        _TinyInfoRow(
                          icon: Icons.medication_rounded,
                          text: "${order.medicines!.length} أدوية",
                          color: AppColors.successForeground,
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(width: 8.w),

                Container(
                  width: 34.w,
                  height: 34.w,
                  decoration: BoxDecoration(
                    color: const Color(0xffF4F6FA),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14.sp,
                    color: AppColors.textSecondaryParagraph,
                  ),
                ),
              ],
            ),

            if (hasPrice) ...[
              SizedBox(height: 12.h),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xffF8FAFC),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.payments_rounded,
                        size: 16.sp,
                        color: AppColors.primary,
                      ),
                    ),

                    SizedBox(width: 10.w),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text: "إجمالي الطلب",
                          textStyle: t.xsRegular.copyWith(
                            color: AppColors.textSecondaryParagraph,
                          ),
                        ),

                        SizedBox(height: 2.h),

                        AppText(
                          text: "${order.finalAmount!.toStringAsFixed(0)} ج.م",
                          textStyle: t.mdBold.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    AppText(
                      text: "التفاصيل",
                      textStyle: t.xsMedium.copyWith(
                        color: AppColors.textSecondaryParagraph,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // helpers

  String? get _firstImage {
    for (final u in [
      order.prescriptionUrl1,
      order.prescriptionUrl2,
      order.prescriptionUrl3,
      order.prescriptionUrl4,
      order.prescriptionUrl5,
    ]) {
      if (u != null && u.isNotEmpty) {
        return u;
      }
    }

    return null;
  }

  String _formatDate(int? ts) {
    if (ts == null) return '—';

    final dt = DateTime.fromMillisecondsSinceEpoch(ts);

    const m = [
      'يناير',
      'فبراير',
      'مارس',
      'إبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
  }

  (Color, String) _statusCfg(String s) {
    switch (s) {
      case 'delivered':
        return (AppColors.successForeground, 'تم التوصيل');

      case 'completed':
        return (AppColors.successForeground, 'مكتمل');

      case 'order_confirmed':
        return (AppColors.primary, 'تم التأكيد');

      default:
        return (AppColors.successForeground, 'مكتمل');
    }
  }
}

// ─────────────────────────────
// THUMB
// ─────────────────────────────

class _Thumb extends StatelessWidget {
  final String? url;

  const _Thumb({required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80.w,
      height: 80.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: const Color(0xffF4F6FA),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child:
            url != null
                ? CachedNetworkImage(imageUrl: url!, fit: BoxFit.cover)
                : Icon(
                  Icons.description_rounded,
                  color: AppColors.primary,
                  size: 26.sp,
                ),
      ),
    );
  }
}

// ─────────────────────────────
// STATUS
// ─────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: AppText(
        text: label,
        textStyle: context.typography.xsMedium.copyWith(
          color: color,
          fontSize: 11.sp,
        ),
      ),
    );
  }
}

// ─────────────────────────────
// INFO ROW
// ─────────────────────────────

class _TinyInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _TinyInfoRow({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: color),

        SizedBox(width: 5.w),

        Expanded(
          child: AppText(
            text: text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textStyle: context.typography.xsRegular.copyWith(
              color: AppColors.textSecondaryParagraph,
              fontSize: 11.5.sp,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATES
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool hasOrders;

  const _EmptyState({required this.hasOrders});

  @override
  Widget build(BuildContext context) {
    final t = context.typography;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96.w,
              height: 96.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasOrders
                    ? Icons.hourglass_top_rounded
                    : Icons.medical_information_outlined,
                size: 44.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 20.h),
            AppText(
              text: hasOrders ? 'طلباتك تحت المراجعة' : 'سجلك الطبي فاضل',
              textStyle: t.lgBold.copyWith(color: AppColors.textDisplay),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            AppText(
              text:
                  hasOrders
                      ? 'بعد ما الصيدلية توصّلك الدواء،\nالروشتة هتتسجل هنا تلقائياً'
                      : 'لما تطلب دواء وتوصلك الروشتة\nهتتسجل هنا تلقائياً',
              textStyle: t.smRegular.copyWith(
                color: AppColors.textSecondaryParagraph,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            if (!hasOrders) ...[
              SizedBox(height: 28.h),
              GestureDetector(
                onTap: () {
                  final user = Get.find<UserSession>().user;
                  final reservation = ReservationModel(
                    patientUid: user?.user.uid,
                    patientFcm: user?.user.fcmToken,
                    patientPhone: user?.user.phone,
                    patientName: user?.user.name,
                  );
                  Get.to(
                    () => OrderMedicineScreen(
                      reservation: reservation,
                      onConfirmed: (_) => Get.back(),
                    ),
                    binding: Binding(),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 28.w,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: AppText(
                    text: 'اطلب دواء دلوقتي 💊',
                    textStyle: t.mdBold.copyWith(color: AppColors.white),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
