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
    this.from_home,
  });

  Color get _statusColor {
    switch (order.status) {
      case "pending":
        return AppColors.not_start;
      case "processing":
        return AppColors.tag_icon_warning;
      case "calculated":
        return AppColors.blueForeground;
      case "confirmed":
      case "approved":
      case "delivered":
        return AppColors.primary;
      case "completed":
        return AppColors.blueForeground;
      case "cancelled":
        return AppColors.errorForeground;
      default:
        return AppColors.grayLight;
    }
  }

  String get _statusLabel {
    switch (order.status) {
      case "pending":
        return "قيد الانتظار";
      case "processing":
        return "جاري حساب السعر";
      case "calculated":
        return "في انتظار الموافقة";
      case "confirmed":
        return "تمت الموافقة";
      case "approved":
        return "جاري التسعير";
      case "delivered":
        return "تم التوصيل";
      case "completed":
        return "تم إرسال الطلب";
      case "cancelled":
        return "ملغي";
      default:
        return order.status ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.typography;
    final statusColor = _statusColor;
    final isHome = from_home == true;

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.18),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── COLORED HEADER ─────────────────────────────────
          _StatusHeader(
            t: t,
            statusColor: statusColor,
            statusLabel: _statusLabel,
            patientName: order.patientName ?? "غير معروف",
            createdAt: order.createdAt,
          ),

          // ── CARD BODY ──────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Full card extras (not home)
                if (!isHome) ...[
                  if (order.doctorName != null) ...[
                    _InfoRow(
                      icon: Icons.medical_services_rounded,
                      label: "الطبيب",
                      value: "د. ${order.doctorName}",
                      iconColor: AppColors.primary,
                    ),
                    SizedBox(height: 10.h),
                  ],
                  _InfoRow(
                    icon: Icons.phone_rounded,
                    label: "رقم المريض",
                    value: order.phone ?? "لا يوجد",
                  ),
                  SizedBox(height: 10.h),
                  _InfoRow(
                    icon: Icons.location_on_rounded,
                    label: "العنوان",
                    value: order.address ?? "غير متوفر",
                  ),
                  SizedBox(height: 16.h),
                  const Divider(color: Color(0xFFEEF2F6), height: 1),
                  SizedBox(height: 16.h),
                ],

                // PRICE HERO
                _PriceHero(order: order, t: t, statusColor: statusColor),
                SizedBox(height: 10.h),

                // PRICE ACTION BUTTON
                _PriceActionButton(
                  order: order,
                  t: t,
                  onPriceDetails: onPriceDetails,
                ),
                SizedBox(height: 12.h),

                // ACTION BUTTONS
                OrderButtonBar(
                  status: order.status ?? "",
                  onPrimaryTap: onConfirmOrder,
                  onDetailsTap: onOrderDetails,
                  onCancelTap: onCancelOrder,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

// ─────────────────────────────────────────────────────────────────────────────
// COLORED STATUS HEADER
// ─────────────────────────────────────────────────────────────────────────────
class _StatusHeader extends StatelessWidget {
  final AppTypography t;
  final Color statusColor;
  final String statusLabel;
  final String patientName;
  final int? createdAt;

  const _StatusHeader({
    required this.t,
    required this.statusColor,
    required this.statusLabel,
    required this.patientName,
    this.createdAt,
  });

  String _formatDate(int ts) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ts);
    return "${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(17.r),
          topRight: Radius.circular(17.r),
        ),
        border: Border(
          bottom: BorderSide(
            color: statusColor.withValues(alpha: 0.14),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Status dot + label + name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status row
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      statusLabel,
                      style: t.smMedium.copyWith(color: statusColor),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                // Patient name
                Text(
                  patientName,
                  style: t.lgBold.copyWith(color: AppColors.textDisplay),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (createdAt != null) ...[
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 13,
                        color: AppColors.textSecondaryParagraph,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        _formatDate(createdAt!),
                        style: t.smRegular.copyWith(
                          color: AppColors.textSecondaryParagraph,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // ── Pharmacy icon badge
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.medical_services_rounded,
              size: 22.w,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PRICE HERO
// ─────────────────────────────────────────────────────────────────────────────
class _PriceHero extends StatelessWidget {
  final OrderModel order;
  final AppTypography t;
  final Color statusColor;

  const _PriceHero({
    required this.order,
    required this.t,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final hasPrice = order.finalAmount != null && order.finalAmount! > 0;
    final priceColor =
        hasPrice ? AppColors.primary : AppColors.tag_icon_warning;
    final isCalculated = order.status == "calculated";

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: priceColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: priceColor.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          // Icon bubble
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: priceColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.payments_rounded,
              size: 22.w,
              color: priceColor,
            ),
          ),
          SizedBox(width: 12.w),
          // Price info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "السعر النهائي",
                  style: t.smMedium.copyWith(
                      color: AppColors.textSecondaryParagraph),
                ),
                SizedBox(height: 3.h),
                Text(
                  hasPrice
                      ? "${order.finalAmount} ج.م"
                      : "جارٍ تجهيز السعر",
                  style: t.xlBold.copyWith(
                    color: priceColor,
                    letterSpacing: -0.5,
                  ),
                ),
                if (isCalculated) ...[
                  SizedBox(height: 3.h),
                  Text(
                    "تم تحديد السعر – يحتاج تأكيد",
                    style: t.smMedium.copyWith(color: AppColors.primary),
                  ),
                ],
                if (hasPrice) ...[
                  SizedBox(height: 3.h),
                  Text(
                    "شامل التوصيل والخصم",
                    style: t.smRegular.copyWith(
                        color: AppColors.textSecondaryParagraph),
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

// ─────────────────────────────────────────────────────────────────────────────
// PRICE ACTION BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _PriceActionButton extends StatelessWidget {
  final OrderModel order;
  final AppTypography t;
  final VoidCallback? onPriceDetails;

  const _PriceActionButton({
    required this.order,
    required this.t,
    this.onPriceDetails,
  });

  @override
  Widget build(BuildContext context) {
    final hasPrice = order.finalAmount != null && order.finalAmount! > 0;
    final isConfirmed = order.status == "confirmed" || order.status == "completed";

    final label = isConfirmed
        ? "تفاصيل سعر الروشتة"
        : hasPrice
            ? "راجع السعر وأكد الطلب"
            : "بانتظار تسعير الصيدلية";

    return GestureDetector(
      onTap: hasPrice ? onPriceDetails : null,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: hasPrice ? AppColors.primary : const Color(0xFFF1F3F5),
          borderRadius: BorderRadius.circular(12.r),
          border: hasPrice
              ? null
              : Border.all(color: const Color(0xFFDDE1E7)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!hasPrice)
              Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: Icon(
                  Icons.hourglass_empty_rounded,
                  size: 16,
                  color: AppColors.textSecondaryParagraph,
                ),
              ),
            Text(
              label,
              style: t.mdBold.copyWith(
                color: hasPrice
                    ? AppColors.white
                    : AppColors.textSecondaryParagraph,
              ),
            ),
            if (hasPrice) ...[
              SizedBox(width: 8.w),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INFO ROW
// ─────────────────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.typography;
    final color = iconColor ?? AppColors.primary;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(7.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16.w, color: color),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: t.smRegular.copyWith(
                    color: AppColors.textSecondaryParagraph),
              ),
              Text(
                value,
                style: t.smMedium.copyWith(color: AppColors.textDisplay),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
