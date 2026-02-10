import '../../../../../index/index_main.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onPriceDetails;
  final VoidCallback? onConfirmOrder;
  final VoidCallback? onCancelOrder;
  final VoidCallback? onFollowTreatment;
  final VoidCallback? onOrderDetails;
  final bool? from_home;

  const OrderCard({
    super.key,
    required this.order,
    this.onPriceDetails,
    this.onConfirmOrder,
    this.onCancelOrder,
    this.onFollowTreatment,
    this.onOrderDetails,
    this.from_home
  });

  @override
  Widget build(BuildContext context) {
    final t = context.typography;

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderNeutralPrimary),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //----------------------------------------------------------
          // HEADER → Patient Name + Status Badge + Created Date
          //----------------------------------------------------------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppText(
                  text: order.patientName ?? "غير معروف",
                  textStyle: t.lgBold.copyWith(color: AppColors.textDisplay),
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  PharmacyOrderStatusBadge(status: order.status ?? "pending"),

                  if (order.createdAt != null) ...[
                    SizedBox(height: 6.h),
                    AppText(
                      text: _formatDate(order.createdAt!),
                      textStyle: t.xsRegular.copyWith(
                        color: AppColors.textSecondaryParagraph,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          SizedBox(height: 10.h),
          const Divider(color: AppColors.borderNeutralPrimary, height: 1),
          SizedBox(height: 10.h),

          //----------------------------------------------------------
          // SUBHEADER → Doctor Name
          //----------------------------------------------------------
     from_home == true ?const SizedBox():     order.doctorName == null
              ? const SizedBox()
              : _richInfoRow(
                  icon: Icons.medical_services_rounded,
                  label: "الطبيب",
                  value: "د. ${order.doctorName ?? "غير معروف"}",
                  color: AppColors.primary,
                ),

          from_home == true ?const SizedBox():  SizedBox(height: 12.h),

          //----------------------------------------------------------
          // CONTACT INFO → Phone
          //----------------------------------------------------------
          from_home == true ?const SizedBox():   _richInfoRow(
            icon: Icons.phone,
            label: "رقم المريض",
            value: order.phone ?? "لا يوجد",
          ),

          from_home == true ?const SizedBox():   SizedBox(height: 12.h),

          //----------------------------------------------------------
          // ADDRESS
          //----------------------------------------------------------
          from_home == true ?const SizedBox():   _richInfoRow(
            icon: Icons.location_on_outlined,
            label: "العنوان",
            value: order.address ?? "غير متوفر",
          ),

          from_home == true ?const SizedBox():    SizedBox(height: 16.h),
          from_home == true ?const SizedBox():    const Divider(color: AppColors.borderNeutralPrimary, height: 1),
          from_home == true ?const SizedBox():    SizedBox(height: 16.h),

          //----------------------------------------------------------
          // TOTAL PRICE
          //----------------------------------------------------------
          // Padding(
          //   padding: const EdgeInsets.only(bottom: 10.0),
          //   child: Row(
          //     children: [
          //       Expanded(
          //         child: Row(
          //           children: [
          //             AppText(
          //               text: "إجمالي الطلب",
          //               textStyle: t.mdMedium.copyWith(
          //                 color: AppColors.textSecondaryParagraph,
          //               ),
          //             ),
          //             const SizedBox(width: 15),
          //             AppText(
          //               text: "${order.finalAmount ?? 0} ج.م",
          //               textStyle: t.xlBold.copyWith(
          //                 color: AppColors.textDisplay,
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //
          //       PrimaryTextButton(
          //         onTap: order.finalAmount == null || order.finalAmount == 0
          //             ? () {
          //                 Loader.showInfo(
          //                   "جارٍ تجهيز تفاصيل السعر... يرجى الانتظار دقائق وسيتم إرسالها لك لإتمام تأكيد الطلب.",
          //                 );
          //               }
          //             : onPriceDetails,
          //         appButtonSize: AppButtonSize.small,
          //         customBackgroundColor: AppColors.white,
          //         customBorder: const BorderSide(
          //           color: AppColors.borderNeutralPrimary,
          //           width: 1,
          //         ),
          //         label: AppText(
          //           text: "عرض تفاصيل السعر",
          //           textStyle: t.xsMedium.copyWith(
          //             color: AppColors.textDisplay,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          _priceHero(t),
          SizedBox(height: 12.h),
          _priceActionButton(t),
          SizedBox(height: 16.h),

          //----------------------------------------------------------
          // ACTION BUTTONS
          //----------------------------------------------------------
          OrderButtonBar(
            status: order.status ?? "",
            onPrimaryTap: onConfirmOrder,
            onDetailsTap: onOrderDetails,
            onCancelTap: onCancelOrder,
          ),
        ],
      ),
    );
  }

  Widget _priceHero(AppTypography t) {
    final hasPrice = order.finalAmount != null && order.finalAmount! > 0;
    final isCalculated = order.status == "calculated";

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: hasPrice
            ? LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.12),
                  AppColors.primary.withOpacity(0.04),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              )
            : null,
        color: hasPrice ? null : AppColors.tag_icon_warning.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: hasPrice
              ? AppColors.primary.withOpacity(0.25)
              : AppColors.tag_icon_warning.withOpacity(0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title
          Row(
            children: [
              Icon(
                Icons.payments_rounded,
                color: hasPrice
                    ? AppColors.primary
                    : AppColors.tag_icon_warning,
              ),
              SizedBox(width: 8.w),
              AppText(
                text: "السعر النهائي",
                textStyle: t.smMedium.copyWith(
                  color: AppColors.textSecondaryParagraph,
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // ── Price
          AppText(
            text: hasPrice ? "${order.finalAmount} ج.م" : "جارٍ تجهيز السعر",
            textStyle: t.xlBold.copyWith(
              letterSpacing: -0.5,
              color: hasPrice ? AppColors.primary : AppColors.tag_icon_warning,
            ),
          ),

          // ✅ هنا بالظبط
          if (isCalculated) ...[
            SizedBox(height: 6.h),
            AppText(
              text: "تم تحديد السعر – يحتاج تأكيد",
              textStyle: t.xsMedium.copyWith(color: AppColors.primary),
            ),
          ],

          // Optional subtitle
          if (hasPrice) ...[
            SizedBox(height: 4.h),
            AppText(
              text: "شامل التوصيل والخصم",
              textStyle: t.xsRegular.copyWith(
                color: AppColors.textSecondaryParagraph,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _priceActionButton(AppTypography t) {
    final hasPrice = order.finalAmount != null && order.finalAmount! > 0;

    return GestureDetector(
      onTap: hasPrice ? onPriceDetails : null,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: hasPrice ? AppColors.primary : AppColors.borderNeutralPrimary,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppText(
              text: order.status == "confirmed"
                  ? "تفاصيل سعر الروشتة"
                  : hasPrice
                  ? "راجع السعر وأكد الطلب"
                  : "بانتظار تسعير الصيدلية",
              textStyle: t.mdBold.copyWith(
                color: hasPrice
                    ? AppColors.white
                    : AppColors.textSecondaryParagraph,
              ),
            ),
            if (hasPrice) ...[
              SizedBox(width: 8.w),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.white,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // PROFESSIONAL RICH INFO ROW
  // ---------------------------------------------------------
  Widget _richInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: (color ?? AppColors.primary).withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16.w, color: color ?? AppColors.primary),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: label,
                textStyle: Get.context!.typography.xsRegular.copyWith(
                  color: AppColors.textSecondaryParagraph,
                ),
              ),
              AppText(
                text: value,
                textStyle: Get.context!.typography.smMedium.copyWith(
                  color: AppColors.textDisplay,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------
  // DATE FORMATTER
  // ---------------------------------------------------------
  String _formatDate(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return "${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}";
  }
}
