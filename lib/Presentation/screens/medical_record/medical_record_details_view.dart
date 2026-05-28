import '../../../index/index_main.dart';

class MedicalRecordDetailsView extends StatelessWidget {
  final OrderModel order;

  const MedicalRecordDetailsView({super.key, required this.order});

  // ── prescription images (non-null, non-empty)
  List<String> get _images => [
        order.prescriptionUrl1,
        order.prescriptionUrl2,
        order.prescriptionUrl3,
        order.prescriptionUrl4,
        order.prescriptionUrl5,
      ].where((e) => e != null && e.isNotEmpty).cast<String>().toList();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            // ── Sliver AppBar with gradient header
            SliverAppBar(
              expandedHeight: 200.h,
              pinned: true,
              backgroundColor: AppColors.primary,
              leading: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  margin: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  // arrow_back_ios_new في RTL يُعكس تلقائياً → يظهر → (رجوع)
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: _HeaderBackground(order: order),
              ),
            ),

            // ── Body
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 60.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Prescription Photos
                  _PrescriptionSection(images: _images),
                  SizedBox(height: 16.h),

                  // ── Medicines
                  _MedicinesSection(medicines: order.medicines),
                  SizedBox(height: 16.h),

                  // ── Financial Summary
                  _FinancialSection(order: order),
                  SizedBox(height: 16.h),

                  // ── Meta Info
                  _MetaSection(order: order),
                ]),
              ),
            ),
          ],
        ),

        // ── Bottom CTA
        bottomNavigationBar: _BottomCTA(order: order),
      ),
    );
  }
}

// ============================================================
// 🎨 HEADER BACKGROUND
// ============================================================

class _HeaderBackground extends StatelessWidget {
  final OrderModel order;

  const _HeaderBackground({required this.order});

  @override
  Widget build(BuildContext context) {
    final t = context.typography;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.7),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Icon + Date row
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.medical_information_rounded,
                      color: Colors.white,
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: "سجل طبي",
                        textStyle: t.xsRegular.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      AppText(
                        text: _formatDate(order.createdAt),
                        textStyle: t.lgBold.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 14.h),

              // Doctor name chip
              if (order.doctorName != null &&
                  order.doctorName!.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        color: Colors.white,
                        size: 14.sp,
                      ),
                      SizedBox(width: 6.w),
                      AppText(
                        text: "د. ${order.doctorName}",
                        textStyle: t.smMedium.copyWith(
                          color: Colors.white,
                        ),
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

  String _formatDate(int? ts) {
    if (ts == null) return "—";
    final dt = DateTime.fromMillisecondsSinceEpoch(ts);
    const months = [
      "يناير",
      "فبراير",
      "مارس",
      "إبريل",
      "مايو",
      "يونيو",
      "يوليو",
      "أغسطس",
      "سبتمبر",
      "أكتوبر",
      "نوفمبر",
      "ديسمبر",
    ];
    return "${dt.day} ${months[dt.month - 1]} ${dt.year}";
  }
}

// ============================================================
// 📸 PRESCRIPTION PHOTOS SECTION
// ============================================================

class _PrescriptionSection extends StatelessWidget {
  final List<String> images;

  const _PrescriptionSection({required this.images});

  @override
  Widget build(BuildContext context) {
    final t = context.typography;

    return _SectionCard(
      icon: Icons.camera_alt_rounded,
      title: "صور الروشتة",
      child: images.isEmpty
          ? Container(
              padding: EdgeInsets.symmetric(
                  vertical: 20.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.image_search_rounded,
                    size: 22.sp,
                    color: AppColors.textSecondaryParagraph,
                  ),
                  SizedBox(width: 10.w),
                  AppText(
                    text: "لا توجد صور للروشتة",
                    textStyle: t.smRegular.copyWith(
                      color: AppColors.textSecondaryParagraph,
                    ),
                  ),
                ],
              ),
            )
          : SizedBox(
              height: 200.h,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: images.asMap().entries.map((entry) {
                    final i = entry.key;
                    final imgWidth =
                        images.length == 1 ? 300.w : 150.w;
                    return Padding(
                      padding:
                          EdgeInsets.only(left: i > 0 ? 10.w : 0),
                      child: GestureDetector(
                        onTap: () => Get.to(
                          () => _FullScreenImage(
                            images: images,
                            initialIndex: i,
                          ),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(14.r),
                              child: CachedNetworkImage(
                                imageUrl: images[i],
                                width: imgWidth,
                                height: 200.h,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  width: imgWidth,
                                  height: 200.h,
                                  color: AppColors.background,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                ),
                                errorWidget: (_, __, ___) =>
                                    Container(
                                  width: imgWidth,
                                  height: 200.h,
                                  color: AppColors.background,
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    color: AppColors
                                        .textSecondaryParagraph,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 8.h,
                              right: 8.w,
                              child: Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  color: Colors.black
                                      .withValues(alpha: 0.5),
                                  borderRadius:
                                      BorderRadius.circular(6.r),
                                ),
                                child: Icon(
                                  Icons.zoom_in_rounded,
                                  color: Colors.white,
                                  size: 14.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
    );
  }
}

// ============================================================
// 💊 MEDICINES SECTION
// ============================================================

class _MedicinesSection extends StatelessWidget {
  final List<MedicineItemModel>? medicines;

  const _MedicinesSection({this.medicines});

  @override
  Widget build(BuildContext context) {
    final t = context.typography;
    final hasMedicines = medicines != null && medicines!.isNotEmpty;

    return _SectionCard(
      icon: Icons.medication_rounded,
      title: "الأدوية الموصوفة",
      iconColor: AppColors.successForeground,
      child: hasMedicines
          ? Column(
              children: [
                ...medicines!.asMap().entries.map(
                      (entry) => _MedicineRow(
                        medicine: entry.value,
                        index: entry.key,
                        isLast:
                            entry.key == medicines!.length - 1,
                      ),
                    ),
              ],
            )
          : Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18.sp,
                    color: AppColors.textSecondaryParagraph,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: AppText(
                      text:
                          "الصيدلية لم تُدخل تفاصيل الأدوية بعد",
                      textStyle: t.smRegular.copyWith(
                        color: AppColors.textSecondaryParagraph,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _MedicineRow extends StatelessWidget {
  final MedicineItemModel medicine;
  final int index;
  final bool isLast;

  const _MedicineRow({
    required this.medicine,
    required this.index,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.typography;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Row(
            children: [
              // Number badge
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: AppColors.successForeground.withValues(
                    alpha: 0.1,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: AppText(
                    text: "${index + 1}",
                    textStyle: t.xsMedium.copyWith(
                      color: AppColors.successForeground,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),

              // Name + type
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: medicine.name ?? "دواء غير محدد",
                      textStyle: t.smMedium.copyWith(
                        color: AppColors.textDisplay,
                      ),
                    ),
                    if (medicine.type != null &&
                        medicine.type!.isNotEmpty)
                      AppText(
                        text: medicine.type!,
                        textStyle: t.xsRegular.copyWith(
                          color: AppColors.textSecondaryParagraph,
                        ),
                      ),
                  ],
                ),
              ),

              // Qty + Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (medicine.quantity != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(
                          alpha: 0.08,
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: AppText(
                        text: "× ${medicine.quantity}",
                        textStyle: t.xsMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  if (medicine.price != null &&
                      medicine.price! > 0) ...[
                    SizedBox(height: 4.h),
                    AppText(
                      text:
                          "${medicine.price?.toStringAsFixed(0)} ج.م",
                      textStyle: t.xsRegular.copyWith(
                        color: AppColors.textSecondaryParagraph,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: AppColors.borderNeutralPrimary,
          ),
      ],
    );
  }
}

// ============================================================
// 💰 FINANCIAL SECTION
// ============================================================

class _FinancialSection extends StatelessWidget {
  final OrderModel order;

  const _FinancialSection({required this.order});

  @override
  Widget build(BuildContext context) {
    final hasPrice =
        order.finalAmount != null && order.finalAmount! > 0;

    if (!hasPrice && order.totalOrder == null) {
      return const SizedBox.shrink();
    }

    return _SectionCard(
      icon: Icons.receipt_long_rounded,
      title: "ملخص الطلب",
      child: Column(
        children: [
          if (order.totalOrder != null && order.totalOrder! > 0)
            _FinancialRow(
              label: "سعر الروشتة",
              value: "${order.totalOrder?.toStringAsFixed(0)} ج.م",
            ),
          if (order.discount != null && order.discount! > 0)
            _FinancialRow(
              label: "الخصم",
              value: "- ${order.discount?.toStringAsFixed(0)} ج.م",
              valueColor: AppColors.successForeground,
            ),
          if (order.deliveryFees != null && order.deliveryFees! > 0)
            _FinancialRow(
              label: "التوصيل",
              value:
                  "+ ${order.deliveryFees?.toStringAsFixed(0)} ج.م",
            ),
          if (hasPrice) ...[
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Divider(
                color: AppColors.borderNeutralPrimary,
                height: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.h),
              child: _FinancialRow(
                label: "الإجمالي النهائي",
                value:
                    "${order.finalAmount?.toStringAsFixed(0)} ج.م",
                isBold: true,
                valueColor: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FinancialRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _FinancialRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.typography;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            text: label,
            textStyle: t.smRegular.copyWith(
              color: AppColors.textSecondaryParagraph,
            ),
          ),
          AppText(
            text: value,
            textStyle: (isBold ? t.mdBold : t.smMedium).copyWith(
              color: valueColor ?? AppColors.textDisplay,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ℹ️ META INFO SECTION
// ============================================================

class _MetaSection extends StatelessWidget {
  final OrderModel order;

  const _MetaSection({required this.order});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.info_outline_rounded,
      title: "معلومات إضافية",
      iconColor: AppColors.textSecondaryParagraph,
      child: Column(
        children: [
          _MetaRow(
            label: "مصدر الطلب",
            value: order.createdBy == "whatsapp"
                ? "واتساب"
                : "التطبيق",
            icon: order.createdBy == "whatsapp"
                ? Icons.chat_rounded
                : Icons.phone_android_rounded,
          ),
          if (order.pharmacyName != null &&
              order.pharmacyName!.isNotEmpty)
            _MetaRow(
              label: "الصيدلية",
              value: order.pharmacyName!,
              icon: Icons.local_pharmacy_rounded,
            ),
          if (order.notes != null && order.notes!.isNotEmpty)
            _MetaRow(
              label: "ملاحظات",
              value: order.notes!,
              icon: Icons.sticky_note_2_outlined,
            ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetaRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.typography;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16.sp,
            color: AppColors.textSecondaryParagraph,
          ),
          SizedBox(width: 10.w),
          AppText(
            text: label,
            textStyle: t.smRegular.copyWith(
              color: AppColors.textSecondaryParagraph,
            ),
          ),
          const Spacer(),
          AppText(
            text: value,
            textStyle: t.smMedium.copyWith(
              color: AppColors.textDisplay,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 🃏 SECTION CARD WRAPPER
// ============================================================

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final Color? iconColor;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.typography;
    final color = iconColor ?? AppColors.primary;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderNeutralPrimary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, size: 16.sp, color: color),
              ),
              SizedBox(width: 10.w),
              AppText(
                text: title,
                textStyle: t.mdBold.copyWith(
                  color: AppColors.textDisplay,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          child,
        ],
      ),
    );
  }
}

// ============================================================
// 🚀 BOTTOM CTA
// ============================================================

class _BottomCTA extends StatelessWidget {
  final OrderModel order;

  const _BottomCTA({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 28.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.borderNeutralPrimary),
        ),
      ),
      child: GestureDetector(
        onTap: _orderAgain,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.replay_rounded,
                color: Colors.white,
                size: 18,
              ),
              SizedBox(width: 8.w),
              AppText(
                text: "طلب نفس الروشتة مرة أخرى",
                textStyle: context.typography.mdBold.copyWith(
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _orderAgain() {
    final user = Get.find<UserSession>().user;

    final images = [
      order.prescriptionUrl1,
      order.prescriptionUrl2,
      order.prescriptionUrl3,
      order.prescriptionUrl4,
      order.prescriptionUrl5,
    ].where((u) => u != null && u.isNotEmpty).cast<String>().toList();

    final reservation = ReservationModel(
      patientUid: user?.user.uid ?? order.patientuid,
      patientFcm: user?.user.fcmToken ?? order.fcmToken,
      patientPhone: user?.user.phone ?? order.phone,
      patientName: user?.user.name ?? order.patientName,
    );

    Get.to(
      () => OrderMedicineScreen(
        reservation: reservation,
        onConfirmed: (_) => Get.back(),
        preloadedImageUrls: images,
        preloadedMedicines: order.medicines ?? [],
      ),
      binding: Binding(),
    );
  }
}

// ============================================================
// 🖼️ FULLSCREEN IMAGE VIEWER WITH SWIPE
// ============================================================

class _FullScreenImage extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullScreenImage({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_FullScreenImage> createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<_FullScreenImage> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController =
        PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.close, color: Colors.white),
        ),
        title: AppText(
          text:
              "${_currentIndex + 1} / ${widget.images.length}",
          textStyle: context.typography.mdMedium.copyWith(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (i) =>
            setState(() => _currentIndex = i),
        itemBuilder: (_, i) => InteractiveViewer(
          child: Center(
            child: CachedNetworkImage(
              imageUrl: widget.images[i],
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
