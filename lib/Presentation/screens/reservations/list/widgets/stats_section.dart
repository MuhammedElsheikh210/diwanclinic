import 'package:diwanclinic/index/index_main.dart';

class StatsSection extends StatelessWidget {
  final ReservationViewModel controller;

  const StatsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final all = controller.completeDayReservations;

    final completed = all
        .where((r) => r.status == ReservationStatus.completed.value)
        .length;

    final pending = all
        .where(
          (r) =>
              r.status == ReservationStatus.approved.value ||
              r.status == ReservationStatus.inProgress.value,
        )
        .length;

    final total = completed + pending;

    return Container(
      height: 56.h,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderNeutralPrimary),
      ),
      child: Row(
        children: [
          // Title
          _MiniStat(
            label: "المكتملة",
            value: completed,
            color: AppColors.successForeground,
          ),

          const Spacer(),

          _MiniStat(
            label: "المنتظرة",
            value: pending,
            color: AppColors.tag_icon_warning,
          ),

          const Spacer(),

          // Total
          Text(
            "الإجمالي",
            style: context.typography.mdBold.copyWith(
              color: AppColors.textSecondaryParagraph,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            total.toString(),
            style: context.typography.lgBold.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: context.typography.mdBold.copyWith(
            color: AppColors.textSecondaryParagraph,
          ),
        ),
        const SizedBox(width: 7),
        Text(
          value.toString(),
          style: context.typography.lgBold.copyWith(color: color),
        ),
      ],
    );
  }
}
