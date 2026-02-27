import '../../../../../../index/index_main.dart';
import '../details/visit_details_page.dart';

class VisitCardFooter extends StatelessWidget {
  final VisitModel visit;
  final VisitViewModel controller;

  const VisitCardFooter({
    super.key,
    required this.visit,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// ================= STATUS =================
        Text(
          "حالة الزيارة",
          style: typography.smMedium.copyWith(color: Colors.grey.shade600),
        ),

        SizedBox(height: 8.h),

        Wrap(
          spacing: 8.w,
          children: [
            _statusChip(
              context,
              label: "تمت",
              value: "completed",
              color: Colors.green,
            ),
            _statusChip(
              context,
              label: "لم تتم",
              value: "not_completed",
              color: Colors.red,
            ),
          ],
        ),
        const SizedBox(height: 15),

        if (visit.visitStatus == "not_completed" &&
            visit.notCompletedReason != null) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(.05),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: Colors.redAccent, size: 18),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    visit.notCompletedReason!,
                    style: TextStyle(color: Colors.redAccent, fontSize: 13.sp),
                  ),
                ),
              ],
            ),
          ),
        ],

        /// ================= CHECK IN =================
        if (visit.checkInLat == null)
          Container(
            margin: EdgeInsets.only(top: 15.h, bottom: 15.h),
            width: double.infinity,
            height: 46.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              color: Colors.green.withValues(alpha: .08),
              border: Border.all(color: Colors.green.withOpacity(.3)),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14.r),
              onTap: () async {
                await controller.checkInDoctor(visit);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, color: Colors.green, size: 20),
                  SizedBox(width: 6.w),
                  Text(
                    "تسجيل الوصول",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            margin: EdgeInsets.only(top: 15.h, bottom: 15.h),
            padding: EdgeInsets.symmetric(vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(.06),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 18),
                SizedBox(width: 6.w),
                const Text(
                  "تم تسجيل الوصول",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

        /// ================= ACTIONS =================
        Row(
          children: [
            /// 🔥 Primary Button (Details)
            if (visit.visitStatus == "completed")
              Expanded(
                child: Container(
                  height: 44.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14.r),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14.r),
                    onTap: () {
                      // controller.openDetails(visit);
                      Get.to(
                        () => VisitDetailsPage(visit: visit),
                        binding: Binding(),
                      );
                    },
                    child: Center(
                      child: Text(
                        "عرض التفاصيل",
                        style: typography.mdMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            if (visit.visitStatus == "completed") SizedBox(width: 12.w),

            // /// ✏ Edit (Ghost Style)
            // _iconAction(
            //   icon: Icons.edit_rounded,
            //   color: AppColors.primary,
            //   onTap: () {
            //     Get.delete<CreateVisitViewModel>();
            //     showCustomBottomSheet(
            //       context: context,
            //       child: CreateVisitView(doctor: visit),
            //     );
            //   },
            // ),

            SizedBox(width: 8.w),

            /// 🗑 Delete (Subtle Danger)
            _iconAction(
              icon: Icons.delete_outline_rounded,
              color: Colors.redAccent,
              onTap: () {
                controller.deleteVisit(visit);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _statusChip(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    final isSelected = visit.visitStatus == value;

    return GestureDetector(
      onTap: () async {
        if (value == "not_completed") {
          final reason = await _showReasonDialog(context);

          if (reason != null && reason.isNotEmpty) {
            controller.updateVisitStatus(
              visit: visit,
              status: value,
              reason: reason,
            );
          }
        } else {
          controller.updateVisitStatus(visit: visit, status: value);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 1.3,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<String?> _showReasonDialog(BuildContext context) {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("سبب عدم إتمام الزيارة"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "اكتب السبب هنا...",
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              child: const Text("حفظ"),
            ),
          ],
        );
      },
    );
  }

  /// ================= ICON ACTION =================
  Widget _iconAction({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: onTap,
      child: Container(
        height: 44.h,
        width: 44.h,
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}
