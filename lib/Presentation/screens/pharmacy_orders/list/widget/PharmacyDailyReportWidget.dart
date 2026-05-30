import 'package:diwanclinic/index/index_main.dart';

class PharmacyDailyReportWidget extends StatelessWidget {
  final PharmacyOrdersListViewModel controller;

  const PharmacyDailyReportWidget({super.key, required this.controller});

  // المصري:   0-20 → 10%  |  21-50 → 15%  |  50+ → 18%
  double _localPercent(int count) {
    if (count <= 20) return 10.0;
    if (count <= 50) return 15.0;
    return 18.0;
  }

  // المستورد: 0-20 → 2%   |  21-50 → 4%   |  50+ → 6%
  double _importedPercent(int count) {
    if (count <= 20) return 2.0;
    if (count <= 50) return 4.0;
    return 6.0;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
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
    final double localPct = _localPercent(ordersCount);
    final double importedPct = _importedPercent(ordersCount);

    double localSubtotal = 0;
    double importedSubtotal = 0;
    double finalAfterDiscount = 0;

    for (final o in todayOrders) {
      final orderSubtotal = (o.totalOrder ?? 0).toDouble();
      final discount = (o.discount ?? 0).toDouble();
      final discountRate = orderSubtotal == 0 ? 0.0 : discount / orderSubtotal;

      double oLocal = 0;
      double oImported = 0;

      if (o.medicines != null && o.medicines!.isNotEmpty) {
        for (final m in o.medicines!) {
          final lineTotal = ((m.price ?? 0) * (m.quantity ?? 1)).toDouble();
          if (m.isImported) {
            oImported += lineTotal;
          } else {
            oLocal += lineTotal;
          }
        }
      } else {
        oLocal += orderSubtotal;
      }

      localSubtotal += oLocal * (1 - discountRate);
      importedSubtotal += oImported * (1 - discountRate);
      finalAfterDiscount += (o.finalAmount ?? 0).toDouble();
    }

    final double localProfit = localSubtotal * (localPct / 100);
    final double importedProfit = importedSubtotal * (importedPct / 100);
    final double totalProfit = localProfit + importedProfit;

    final String tierLabel = ordersCount <= 20
        ? "0–20 طلب"
        : ordersCount <= 50
            ? "21–50 طلب"
            : "50+ طلب";

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
          // ── عدد الروشتات + الفئة + النسب ──
          _ReportRow(
            title: "الروشتات المكتملة",
            subtitle: "$tierLabel  •  محلي ${localPct.toStringAsFixed(0)}%  •  مستورد ${importedPct.toStringAsFixed(0)}%",
            valueText: ordersCount.toString(),
            icon: Icons.description_rounded,
          ),
          const Divider(height: 20),

          // ── إجمالي ما دفعه المرضى ──
          _ReportRow(
            title: "إجمالي ما دفعه المرضى",
            subtitle: "بعد الخصم + التوصيل",
            valueText: "${finalAfterDiscount.toStringAsFixed(2)} ج.م",
            icon: Icons.summarize_rounded,
          ),
          const Divider(height: 20),

          // ── ربح المحلي ──
          _ReportRow(
            title: "ربح المحلي",
            subtitle: "${localPct.toStringAsFixed(0)}% × ${localSubtotal.toStringAsFixed(0)} ج.م",
            valueText: "${localProfit.toStringAsFixed(2)} ج.م",
            icon: Icons.flag_rounded,
            highlight: true,
          ),

          // ── ربح المستورد ──
          _ReportRow(
            title: "ربح المستورد",
            subtitle: "${importedPct.toStringAsFixed(0)}% × ${importedSubtotal.toStringAsFixed(0)} ج.م",
            valueText: "${importedProfit.toStringAsFixed(2)} ج.م",
            icon: Icons.public_rounded,
            highlight: true,
          ),
          const Divider(height: 20),

          // ── الربح الصافي ──
          _ReportRow(
            title: "ربحك الصافي اليوم",
            subtitle: "محلي + مستورد",
            valueText: "${totalProfit.toStringAsFixed(2)} ج.م",
            icon: Icons.account_balance_wallet_rounded,
            highlight: true,
            primary: true,
          ),
        ],
      ),
    );
  }
}

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
