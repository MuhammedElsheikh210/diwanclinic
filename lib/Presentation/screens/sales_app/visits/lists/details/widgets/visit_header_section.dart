import '../../../../../../../index/index_main.dart';
import 'package:intl/intl.dart';

class VisitHeaderSection extends StatelessWidget {
  final VisitModel visit;

  const VisitHeaderSection({
    super.key,
    required this.visit,
  });

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// 🔹 اسم الدكتور
          Text(
            visit.name ?? "بدون اسم",
            style: typography.lgBold.copyWith(
              fontSize: 18.sp,
              color: AppColors.primary,
            ),
          ),

          SizedBox(height: 12.h),

          /// 🔹 التخصص + التصنيف
          Row(
            children: [
              _badge(
                label: SpecializationMapper.getLabel(
                  visit.specialization,
                ),
                color: Colors.blue,
              ),

              SizedBox(width: 8.w),

              _badge(
                label: "تصنيف ${visit.doctorClass ?? '-'}",
                color: _classColor(visit.doctorClass),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          Divider(
            height: 1,
            color: AppColors.grayLight.withOpacity(0.4),
          ),

          SizedBox(height: 14.h),

          /// 🔹 التاريخ والوقت
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 18, color: Colors.grey.shade600),
              SizedBox(width: 6.w),
              Text(
                _formatDate(visit.visitDate),
                style: typography.smMedium,
              ),

              SizedBox(width: 20.w),

              Icon(Icons.access_time,
                  size: 18, color: Colors.grey.shade600),
              SizedBox(width: 6.w),
              Text(
                visit.visitTime ?? "-",
                style: typography.smMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🔹 Badge Widget
  Widget _badge({
    required String label,
    required Color color,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 6.h,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 🔹 تنسيق التاريخ بالعربي
  String _formatDate(String? date) {
    if (date == null) return "-";
    try {
      final parsed = DateTime.parse(date);
      return DateFormat('dd MMMM yyyy', 'ar')
          .format(parsed);
    } catch (_) {
      return date;
    }
  }

  /// 🔹 لون التصنيف
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