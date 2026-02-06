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
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isClosed
              ? AppColors.errorForeground.withOpacity(0.5)
              : AppColors.primary.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 📅 Date + Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Date
                Text(
                  model.date ?? "",
                  style: context.typography.lgBold.copyWith(
                    color: AppColors.textDisplay,
                  ),
                ),

                SizedBox(height: 12.h),

                /// ✅ Open checkbox
                InkWell(
                  onTap: () {
                    if (isClosed) {
                      controller.toggleDayStatus(
                        model,
                        isClosed: false,
                      );
                    }
                  },
                  child: Row(
                    children: [
                      Checkbox(
                        value: !isClosed,
                        onChanged: (value) {
                          if (value == true) {
                            controller.toggleDayStatus(
                              model,
                              isClosed: false,
                            );
                          }
                        },
                        activeColor: AppColors.primary,
                      ),
                      Text(
                        "اليوم مفتوح للحجوزات",
                        style: context.typography.smMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                /// ❌ Closed checkbox
                InkWell(
                  onTap: () {
                    if (!isClosed) {
                      controller.toggleDayStatus(
                        model,
                        isClosed: true,
                      );
                    }
                  },
                  child: Row(
                    children: [
                      Checkbox(
                        value: isClosed,
                        onChanged: (value) {
                          if (value == true) {
                            controller.toggleDayStatus(
                              model,
                              isClosed: true,
                            );
                          }
                        },
                        activeColor: AppColors.errorForeground,
                      ),
                      Text(
                        "اليوم مغلق للحجوزات",
                        style: context.typography.smMedium.copyWith(
                          color: AppColors.errorForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// ✏️ Edit
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
                height: 26.h,
                width: 26.w,
              ),
            ),
          ),

          SizedBox(width: 8.w),

          /// 🗑 Delete
          InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () => _showConfirmDelete(context),
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: Svgicon(
                icon: IconsConstants.delete_btn,
                height: 26.h,
                width: 26.w,
              ),
            ),
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
