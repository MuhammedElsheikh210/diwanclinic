import 'package:diwanclinic/Presentation/screens/incomes_doctors/income_doctor_view_model.dart';

import '../../../../../index/index_main.dart';

class IncomeDailyReportWidget extends StatelessWidget {
  final IncomeViewModel controller;

  const IncomeDailyReportWidget({super.key, required this.controller});

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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.grayLight, width: 1),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.bar_chart_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "تقرير إيرادات اليوم",
                    style: context.typography.lgBold,
                  ),
                ),
                AnimatedRotation(
                  turns: controller.showDailyReport ? 0.5 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: const Icon(
                    Icons.expand_more,
                    size: 32,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),

        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _reportContent(context),
          crossFadeState: controller.showDailyReport
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),
      ],
    );
  }

  Widget _reportContent(BuildContext context) {
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
          _row(
            context,
            "الكشوف الجديدة",
            controller.newCount,
            controller.newTotal,
          ),
          _row(context, "إعادات الكشف", controller.reCount, controller.reTotal),
          _row(
            context,
            "الكشوف المستعجلة",
            controller.urgentCount,
            controller.urgentTotal,
          ),

          const Divider(),

          _row(
            context,
            "إجمالي اليوم",
            0,
            controller.dayTotal,
            highlight: true,
            showCount: false,
          ),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String title,
    int count,
    double total, {
    bool highlight = false,
    bool showCount = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "$title ${showCount ? "($count)" : ""}",
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
