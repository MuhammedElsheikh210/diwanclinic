import 'package:diwanclinic/index/index_main.dart';

class ReservationReportWidget extends StatelessWidget {
  final ReservationViewModel controller;

  const ReservationReportWidget({Key? key, required this.controller})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            controller.showDailyReport = !controller.showDailyReport;
            controller.update();
          },
          child: Container(
            height: 52,
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderNeutralPrimary),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title
                Text("كشف حساب اليوم", style: context.typography.mdBold),

                const Spacer(),

                // Optional: quick hint
                Text(
                  "عرض التفاصيل",
                  style: context.typography.smMedium.copyWith(
                    color: AppColors.textSecondaryParagraph,
                  ),
                ),

                const SizedBox(width: 6),

                AnimatedRotation(
                  turns: controller.showDailyReport ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: AppColors.textSecondaryParagraph,
                  ),
                ),
              ],
            ),
          ),
        ),

        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: FutureBuilder<List<ReservationModel>>(
            future: controller.queryManager.getCompletedReservationsForReport(
              appointmentDate: controller.appointmentDate,
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              final reservations = snapshot.data!;

              final newCheckups = reservations.where((r) {
                final type = (r.reservationType ?? "").trim();
                return type == "كشف جديد";
              }).toList();

              final urgentCheckups = reservations.where((r) {
                final type = (r.reservationType ?? "").trim();
                final status = r.status;

                return type == "كشف مستعجل" &&
                    status == ReservationStatus.completed.name;
              }).toList();

              final reCheckups = reservations.where((r) {
                final type = (r.reservationType ?? "").trim();
                return type == "إعادة" || type == "متابعة";
              }).toList();

              // Totals
              double newTotal = _sum(newCheckups);
              double reTotal = _sum(reCheckups);
              double urgentTotal = _sum(urgentCheckups);
              double dayTotal = newTotal + reTotal + urgentTotal;

              return _ReportContent(
                newCount: newCheckups.length,
                reCount: reCheckups.length,
                urgentCount: urgentCheckups.length,
                newTotal: newTotal,
                reTotal: reTotal,
                urgentTotal: urgentTotal,
                dayTotal: dayTotal,
              );
            },
          ),
          crossFadeState: controller.showDailyReport
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),
      ],
    );
  }

  double _sum(List<ReservationModel> list) {
    return list.fold(
      0,
      (sum, r) => sum + (double.tryParse(r.paidAmount ?? "") ?? 0),
    );
  }
}

// -------------------------------------------------------
// 🌟 BEAUTIFUL REPORT CONTENT
// -------------------------------------------------------
class _ReportContent extends StatelessWidget {
  final int newCount;
  final int reCount;
  final int urgentCount;

  final double newTotal;
  final double reTotal;
  final double urgentTotal;
  final double dayTotal;

  const _ReportContent({
    Key? key,
    required this.newCount,
    required this.reCount,
    required this.urgentCount,
    required this.newTotal,
    required this.reTotal,
    required this.urgentTotal,
    required this.dayTotal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 1,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _ReportRow(
            "الكشوف الجديدة",
            newCount,
            newTotal,
            icon: Icons.fiber_new_rounded,
          ),
          _ReportRow(
            "إعادات الكشف",
            reCount,
            reTotal,
            icon: Icons.refresh_rounded,
          ),
          _ReportRow(
            "الكشوف المستعجلة",
            urgentCount,
            urgentTotal,
            icon: Icons.flash_on_rounded,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Divider(),
          ),
          _ReportRow(
            "الإجمالي الكلي",
            0,
            dayTotal,
            highlight: true,
            showTotal: false,
            icon: Icons.summarize_rounded,
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------
// 🌟 BEAUTIFUL ROW
// -------------------------------------------------------
class _ReportRow extends StatelessWidget {
  final String title;
  final int count;
  final double total;
  final IconData icon;
  final bool highlight;
  final bool showTotal;

  const _ReportRow(
    this.title,
    this.count,
    this.total, {
    required this.icon,
    this.highlight = false,
    this.showTotal = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: highlight ? AppColors.primary : Colors.grey[600]),
          const SizedBox(width: 8),

          Expanded(
            child: Text(
              "$title ${showTotal ? "($count)" : ""}",
              style: context.typography.mdMedium.copyWith(
                color: highlight
                    ? AppColors.primary
                    : AppColors.background_black,
              ),
            ),
          ),

          Text(
            "${total.toStringAsFixed(2)} ج.م",
            style: context.typography.lgBold.copyWith(
              color: highlight ? AppColors.primary : AppColors.background_black,
            ),
          ),
        ],
      ),
    );
  }
}
