import 'package:diwanclinic/index/index_main.dart';

class PharmacyDailyReportWidget extends StatelessWidget {
  final PharmacyOrdersListViewModel controller;

  const PharmacyDailyReportWidget({super.key, required this.controller});

  /// 🔥 نسبة ربح الصيدلية
  /// أقل من 30 طلب = 10%
  /// 30 طلب أو أكثر = 15%
  double _resolvePharmacyProfitPercent(int ordersCount) {
    return ordersCount < 30 ? 10.0 : 15.0;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          // =======================
          // Header
          // =======================
          GestureDetector(
            onTap: () {
              controller.showDailyReport = !controller.showDailyReport;
              controller.update();
            },
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.grayLight, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.receipt_long_rounded,
                    color: AppColors.primary,
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "تقرير أرباح الصيدلية اليومي",
                      style: context.typography.lgBold,
                    ),
                  ),
                  AnimatedRotation(
                    turns: controller.showDailyReport ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 34,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // =======================
          // Content
          // =======================
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildReportContent(context),
            crossFadeState: controller.showDailyReport
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // 🧮 الحسابات الصح (محاسبيًا)
  // --------------------------------------------------
  Widget _buildReportContent(BuildContext context) {
    final today = DateTime.now();

    final todayOrders = controller.orders.where((o) {
      if (o.createdAt == null) return false;
      final d = DateTime.fromMillisecondsSinceEpoch(o.createdAt!);
      return d.year == today.year &&
          d.month == today.month &&
          d.day == today.day &&
          o.status == "completed";
    }).toList();

    final int ordersCount = todayOrders.length;

    double subtotalTotal = 0; // إجمالي الأدوية قبل الخصم
    double discountTotal = 0; // إجمالي الخصومات
    double deliveryTotal = 0; // إجمالي التوصيل (لا يدخل في الربح)
    double finalAfterDiscount = 0; // ما دفعه المرضى فعليًا
    double profitTotal = 0; // ربحك الصافي

    final double profitPercent = _resolvePharmacyProfitPercent(ordersCount);

    for (final o in todayOrders) {
      final subtotal = (o.totalOrder ?? 0).toDouble();
      final discount = (o.discount ?? 0).toDouble();
      final delivery = (o.deliveryFees ?? 0).toDouble();
      final finalAmount = (o.finalAmount ?? 0).toDouble();

      final discountPercent = subtotal == 0 ? 0 : (discount / subtotal) * 100;

      final netProfitPercent = (profitPercent - discountPercent).clamp(
        0,
        profitPercent,
      );

      final profit = subtotal * (netProfitPercent / 100);

      subtotalTotal += subtotal;
      discountTotal += discount;
      deliveryTotal += delivery;
      finalAfterDiscount += finalAmount;
      profitTotal += profit;
    }

    final double avgDiscountPercent = subtotalTotal == 0
        ? 0
        : (discountTotal / subtotalTotal) * 100;

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grayLight, width: 1),
      ),
      child: Column(
        children: [
          _ReportRow(
            title: "عدد الروشتات",
            subtitle: "طلبات مكتملة اليوم",
            valueText: ordersCount.toString(),
            icon: Icons.description_rounded,
          ),
          _ReportRow(
            title: "إجمالي سعر الروشتات",
            subtitle: "100% (بدون توصيل)",
            valueText: "${subtotalTotal.toStringAsFixed(2)} ج.م",
            icon: Icons.payments_rounded,
          ),
          _ReportRow(
            title: "قيمة الخصم",
            subtitle: "خصم المرضى ${avgDiscountPercent.toStringAsFixed(1)}%",
            valueText: "-${discountTotal.toStringAsFixed(2)} ج.م",
            icon: Icons.discount_rounded,
            negative: true,
          ),
          _ReportRow(
            title: "التوصيل",
            subtitle: "لا يدخل في الربح",
            valueText: "${deliveryTotal.toStringAsFixed(2)} ج.م",
            icon: Icons.delivery_dining_rounded,
          ),
          const Divider(),
          _ReportRow(
            title: "إجمالي ما دفعه المرضى",
            subtitle: "بعد الخصم + التوصيل",
            valueText: "${finalAfterDiscount.toStringAsFixed(2)} ج.م",
            icon: Icons.summarize_rounded,
            highlight: true,
          ),
          const Divider(),
          _ReportRow(
            title: "ربحك الصافي اليوم",
            subtitle:
                "${profitPercent.toStringAsFixed(0)}% من (سعر الأدوية بعد الخصم)",
            valueText: "${profitTotal.toStringAsFixed(2)} ج.م",
            icon: Icons.trending_up_rounded,
            highlight: true,
            primary: true,
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// 🌟 Row reusable
// --------------------------------------------------
class _ReportRow extends StatelessWidget {
  final String title;
  final String valueText;
  final IconData icon;
  final String? subtitle;
  final bool highlight;
  final bool negative;
  final bool primary;

  const _ReportRow({
    required this.title,
    required this.valueText,
    required this.icon,
    this.subtitle,
    this.highlight = false,
    this.negative = false,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    Color valueColor = AppColors.background_black;

    if (negative) valueColor = AppColors.errorForeground;
    if (highlight || primary) valueColor = AppColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: valueColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.typography.mdMedium.copyWith(
                    color: valueColor,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: context.typography.xsRegular.copyWith(
                      color: AppColors.textSecondaryParagraph,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            valueText,
            style: context.typography.lgBold.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}
