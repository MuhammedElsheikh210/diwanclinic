import 'package:diwanclinic/index/index_main.dart';

class StatsSection extends StatelessWidget {
  final ReservationViewModel controller;

  const StatsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderNeutralPrimary),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: "كل الحجوزات",
              value: controller.totalCount,
              color: AppColors.primary,
              background: AppColors.primary.withValues(alpha: .04),
            ),
          ),
          const SizedBox(width: 8),

          Expanded(
            child: _StatCard(
              label: "الحجوزات المنتظرة",
              value: controller.waitingCount,
              color: AppColors.tag_icon_warning,
              background: AppColors.primary.withValues(alpha: .04),
            ),
          ),
          const SizedBox(width: 8),

          Expanded(
            child: _StatCard(
              label: "الحجوزات المكتملة",
              value: controller.completedCount,
              color: AppColors.successForeground,
              background: AppColors.primary.withValues(alpha: .04),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final Color background;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value.toString(),
            style: context.typography.lgBold.copyWith(color: color),
          ),
          Text(
            label,
            style: context.typography.smMedium.copyWith(
              color: AppColors.textSecondaryParagraph,
            ),
          ),
        ],
      ),
    );
  }
}
