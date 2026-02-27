import '../../../../../index/index_main.dart';

class VisitView extends StatefulWidget {
  final String? title;

  const VisitView({super.key, this.title});

  @override
  State<VisitView> createState() => _VisitViewState();
}

class _VisitViewState extends State<VisitView> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: GetBuilder<VisitViewModel>(
        init: VisitViewModel(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: ColorMappingImpl().white,

            /// 🔵 Custom Date AppBar
            appBar: VisitDateAppBar(controller: controller),

            body: controller.listVisits == null
                ? const ShimmerLoader()
                : Column(
              children: [

                /// 🔵 DASHBOARD SUMMARY
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          title: "إجمالي",
                          value: controller.totalVisits,
                          color: AppColors.primary,
                          icon: Icons.analytics_rounded,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _summaryCard(
                          title: "تمت",
                          value: controller.completedVisits,
                          color: Colors.green,
                          icon: Icons.check_circle_rounded,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _summaryCard(
                          title: "لم تتم",
                          value: controller.pendingVisits,
                          color: Colors.orange,
                          icon: Icons.pending_actions_rounded,
                        ),
                      ),
                    ],
                  ),
                ),

                /// 🔹 LIST (Filtered)
                Expanded(
                  child: controller.filteredVisits.isEmpty
                      ? const NoDataWidget()
                      : ListView.builder(
                    padding: EdgeInsets.symmetric(
                        horizontal: 12.w),
                    itemCount:
                    controller.filteredVisits.length,
                    itemBuilder: (context, index) {
                      final visit =
                      controller.filteredVisits[index];

                      return Padding(
                        padding:
                        EdgeInsets.only(bottom: 10.h),
                        child: VisitCard(
                          visit:
                          visit ?? const VisitModel(),
                          controller: controller,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 🔵 Pro Summary Card
  Widget _summaryCard({
    required String title,
    required int value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Top Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18.sp),
              ),
              Text(
                "$value",
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          /// Title
          Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}