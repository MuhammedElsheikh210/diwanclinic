import '../../../../../index/index_main.dart';

class PharmacyOrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onPriceDetails;
  final VoidCallback? onCancel;
  final VoidCallback? onShowPriceDetails;
  final VoidCallback? onConfirmOrder;
  final VoidCallback? onApprovedOrder;
  final VoidCallback? onFollowTreatment;
  final VoidCallback? onOrderDetails;

  const PharmacyOrderCard({
    super.key,
    required this.order,
    this.onPriceDetails,
    this.onCancel,
    this.onShowPriceDetails,
    this.onConfirmOrder,
    this.onApprovedOrder,
    this.onFollowTreatment,
    this.onOrderDetails,
  });

  /// ✅ collect prescription images safely
  List<String> get _prescriptionImages => [
    order.prescriptionUrl1,
    order.prescriptionUrl2,
    order.prescriptionUrl3,
    order.prescriptionUrl4,
    order.prescriptionUrl5,
  ].whereType<String>().where((e) => e.isNotEmpty).toList();

  @override
  Widget build(BuildContext context) {
    final t = context.typography;
    final bool hasPricing = order.finalAmount != null && order.finalAmount! > 0;

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
          // HEADER
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

          SizedBox(height: 12.h),
          const Divider(),
          SizedBox(height: 12.h),

          //----------------------------------------------------------
          // DOCTOR
          //----------------------------------------------------------
          if (order.doctorName != null)
            _richInfoRow(
              icon: Icons.medical_services_rounded,
              label: "الطبيب",
              value: "د. ${order.doctorName}",
              color: AppColors.primary,
            ),

          SizedBox(height: 10.h),

          //----------------------------------------------------------
          // PHONE
          //----------------------------------------------------------
          _richInfoRow(
            icon: Icons.phone,
            label: "رقم المريض",
            value: order.phone ?? "لا يوجد",
          ),

          SizedBox(height: 10.h),

          //----------------------------------------------------------
          // ADDRESS
          //----------------------------------------------------------
          _richInfoRow(
            icon: Icons.location_on_outlined,
            label: "العنوان",
            value: order.address ?? "غير متوفر",
          ),

          SizedBox(height: 14.h),
          const Divider(),
          SizedBox(height: 14.h),
          //----------------------------------------------------------
          // 📝 NOTES / COMMENT
          //----------------------------------------------------------
          if (order.notes != null && order.notes!.trim().isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.sticky_note_2_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text: "ملاحظات",
                          textStyle: t.mdBold.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        AppText(
                          text: order.notes!,
                          textStyle: t.smRegular.copyWith(
                            color: AppColors.textDisplay,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            const Divider(height: 10),
            SizedBox(height: 10.h),
          ],

          //----------------------------------------------------------
          // 🆕 PRESCRIPTION IMAGES
          //----------------------------------------------------------
          PrescriptionShowGallery(images: _prescriptionImages),

          SizedBox(height: 14.h),
          const Divider(),
          SizedBox(height: 14.h),

          //----------------------------------------------------------
          // TOTAL PRICE
          //----------------------------------------------------------
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    AppText(
                      text: "إجمالي الطلب",
                      textStyle: t.mdMedium.copyWith(
                        color: AppColors.textSecondaryParagraph,
                      ),
                    ),
                    const SizedBox(width: 10),
                    AppText(
                      text: "${order.finalAmount ?? 0} ج.م",
                      textStyle: t.xlBold.copyWith(
                        color: AppColors.textDisplay,
                      ),
                    ),
                  ],
                ),
              ),
              !hasPricing
                  ? const SizedBox()
                  : PrimaryTextButton(
                      onTap: !hasPricing ? onPriceDetails : onShowPriceDetails,
                      appButtonSize: AppButtonSize.small,
                      customBackgroundColor: AppColors.white,
                      customBorder: const BorderSide(
                        color: AppColors.borderNeutralPrimary,
                      ),
                      label: AppText(
                        text: "عرض تفاصيل السعر",
                        textStyle: t.mdMedium.copyWith(
                          color: AppColors.textDisplay,
                        ),
                      ),
                    ),
            ],
          ),

          SizedBox(height: 12.h),

          //----------------------------------------------------------
          // ACTION BUTTONS
          //----------------------------------------------------------
          PharmacyOrderButtonBar(
            status: order.status ?? "",
            onPricingTap: onPriceDetails,
            onCancelTap: onCancel,
            onApprovedTap: onApprovedOrder,
            onCompleteTap: onConfirmOrder,
          ),
        ],
      ),
    );
  }

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

  String _formatDate(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return "${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}";
  }
}
