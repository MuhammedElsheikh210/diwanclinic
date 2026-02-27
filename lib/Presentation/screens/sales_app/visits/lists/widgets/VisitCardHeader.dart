import '../../../../../../index/index_main.dart';

class VisitCardHeader extends StatelessWidget {
  final VisitModel visit;

  const VisitCardHeader({super.key, required this.visit});

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Name + Class
        Row(
          children: [
            Expanded(
              child: Text(
                visit.name ?? "بدون اسم",
                style: typography.mdBold.copyWith(
                  color: AppColors.primary,
                  fontSize: 16.sp,
                ),
              ),
            ),
            _chip(
              text: "Class ${visit.doctorClass ?? "-"}",
              color: _classColor(visit.doctorClass),
            ),
          ],
        ),

        SizedBox(height: 6.h),

        /// Specialization
        Text(
          SpecializationMapper.getLabel(visit.specialization),

          style: typography.smRegular.copyWith(color: Colors.grey.shade600),
        ),

        SizedBox(height: 10.h),

        /// Date & Time
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 15, color: Colors.grey),
            SizedBox(width: 6.w),
            Text(visit.visitDate ?? "-"),
            SizedBox(width: 14.w),
            const Icon(Icons.access_time, size: 15, color: Colors.grey),
            SizedBox(width: 6.w),
            Text(visit.visitTime ?? "-"),
          ],
        ),
      ],
    );
  }

  Widget _chip({required String text, required Color color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12.sp,
        ),
      ),
    );
  }

  Color _classColor(String? doctorClass) {
    switch (doctorClass) {
      case "A":
        return Colors.green;
      case "B":
        return Colors.orange;
      case "C":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
