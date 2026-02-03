import '../../../../index/index_main.dart';

class LegacyQueueCard extends StatelessWidget {
  final LegacyQueueModel model;
  final LegacyQueueViewModel controller;

  const LegacyQueueCard({
    super.key,
    required this.model,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.borderNeutralPrimary.withOpacity(0.7),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          /// 📅 Date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.date ?? "",
                  style: context.typography.lgBold.copyWith(
                    color: AppColors.textDisplay,
                  ),
                ),
                SizedBox(height: 6.h),

                /// 🔢 Count Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    "عدد الحجوزات: ${model.value ?? 0}",
                    style: context.typography.smMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// ✏️ Edit
          InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () {
              Get.delete<CreateLegacyQueueViewModel>();
              showCustomBottomSheet(
                context: context,
                child: CreateLegacyQueueView(model: model),
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
          onConfirm: () => _deleteItem(),
        );
      },
    );
  }

  void _deleteItem() {
    controller.deleteItem(model);
    Loader.showSuccess("تم حذف اليوم بنجاح");
  }
}
