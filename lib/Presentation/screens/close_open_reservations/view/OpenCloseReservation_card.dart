import '../../../../index/index_main.dart';

class OpenclosereservationCard extends StatelessWidget {
  final LegacyQueueModel model;
  final OpenclosereservationViewModel controller;

  const OpenclosereservationCard({
    super.key,
    required this.model,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final bool isClosed = model.isClosed ?? false;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color:
              isClosed
                  ? AppColors.errorForeground.withOpacity(.25)
                  : AppColors.primary.withOpacity(.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =====================================================
          // 📅 HEADER
          // =====================================================
          Row(
            children: [
              /// Date
              Expanded(
                child: Text(
                  model.date ?? "",
                  style: context.typography.lgBold.copyWith(
                    color: AppColors.textDisplay,
                  ),
                ),
              ),

              /// Status Chip
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color:
                      isClosed
                          ? AppColors.errorForeground.withValues(alpha: .1)
                          : AppColors.primary.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Text(
                  isClosed ? "مغلق" : "مفتوح",
                  style: context.typography.mdMedium.copyWith(
                    color:
                        isClosed
                            ? AppColors.errorForeground
                            : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // =====================================================
          // 🕒 SHIFT BADGE
          // =====================================================
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 16.sp,
                  color: AppColors.primary,
                ),
                SizedBox(width: 6.w),
                Text(
                  model.shiftName ?? "—",
                  style: context.typography.xsMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 18.h),

          const Divider(height: 1, color: AppColors.grayMedium),

          SizedBox(height: 12.h),

          // =====================================================
          // ✅ ACTIONS
          // =====================================================
          Row(
            children: [
              /// Open
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12.r),
                  onTap: () {
                    if (isClosed) {
                      controller.toggleDayStatus(model, isClosed: false);
                    }
                  },
                  child: Row(
                    children: [
                      Checkbox(
                        value: !isClosed,
                        onChanged: (v) {
                          if (v == true) {
                            controller.toggleDayStatus(model, isClosed: false);
                          }
                        },
                        activeColor: AppColors.primary,
                      ),
                      Text(
                        "مفتوح للحجز",
                        style: context.typography.smMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// Closed
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12.r),
                  onTap: () {
                    if (!isClosed) {
                      controller.toggleDayStatus(model, isClosed: true);
                    }
                  },
                  child: Row(
                    children: [
                      Checkbox(
                        value: isClosed,
                        onChanged: (v) {
                          if (v == true) {
                            controller.toggleDayStatus(model, isClosed: true);
                          }
                        },
                        activeColor: AppColors.errorForeground,
                      ),
                      Text(
                        "مغلق للحجز",
                        style: context.typography.smMedium.copyWith(
                          color: AppColors.errorForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// Edit
              InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  Get.delete<CreateOpenclosereservationViewModel>();
                  showCustomBottomSheet(
                    context: context,
                    child: CreateOpenclosereservationView(model: model),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Svgicon(
                    icon: IconsConstants.edit_btn,
                    height: 24.h,
                    width: 24.w,
                  ),
                ),
              ),

              SizedBox(width: 6.w),

              /// Delete
              InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () => _showConfirmDelete(context),
                child: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Svgicon(
                    icon: IconsConstants.delete_btn,
                    height: 24.h,
                    width: 24.w,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showConfirmDelete(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) {
        return ConfirmBottomSheet(
          title: "هل أنت متأكد من حذف اليوم؟",
          message: "لن تتمكن من استعادة البيانات بعد الحذف.",
          confirmText: "حذف",
          cancelText: "إلغاء",
          onConfirm: _deleteItem,
        );
      },
    );
  }

  void _deleteItem() {
    controller.deleteItem(model);
    Loader.showSuccess("تم حذف اليوم بنجاح");
  }
}
