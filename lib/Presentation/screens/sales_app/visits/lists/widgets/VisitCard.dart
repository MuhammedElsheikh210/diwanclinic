import 'package:diwanclinic/Presentation/screens/sales_app/visits/lists/widgets/VisitCardFooter.dart';
import 'package:diwanclinic/Presentation/screens/sales_app/visits/lists/widgets/VisitCardHeader.dart';

import '../../../../../../index/index_main.dart';

class VisitCard extends StatelessWidget {
  final VisitModel visit;
  final VisitViewModel controller;
  final bool showFooter;

  const VisitCard({
    super.key,
    required this.visit,
    required this.controller,
    this.showFooter = true,
  });

  Color get statusColor {
    switch (visit.visitStatus) {
      case "completed":
        return Colors.green;
      case "not_completed":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.grayLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          /// 🔥 Colored Status Indicator
          Container(
            width: 6.w,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                bottomLeft: Radius.circular(20.r),
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VisitCardHeader(visit: visit),

                  if (showFooter) ...[
                    SizedBox(height: 14.h),
                    Divider(),
                    SizedBox(height: 12.h),
                    VisitCardFooter(visit: visit, controller: controller),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
