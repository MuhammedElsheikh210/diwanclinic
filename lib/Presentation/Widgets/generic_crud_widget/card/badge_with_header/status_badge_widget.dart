import '../../../../../../../index/index_main.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final String label;
  final int dateTimeStamp;
  final Color color; // 🟢 Add this

  const StatusBadge({
    super.key,
    required this.status,
    required this.label,
    required this.dateTimeStamp,
    this.color = Colors.grey, // default
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15), // background tint
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: context.typography.smMedium.copyWith(color: color),
      ),
    );
  }
}
