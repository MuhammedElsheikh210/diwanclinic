import '../../../../../index/index_main.dart';

class ShiftCard extends StatelessWidget {
  final ShiftModel shift;
  final String doctor_key;
  final ShiftViewModel controller;

  const ShiftCard({
    Key? key,
    required this.shift,
    required this.controller,
    required this.doctor_key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
      margin: EdgeInsets.only(bottom: 10.h),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderNeutralPrimary, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // 🔹 Shift Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  shift.name ?? "",
                  style: context.typography.lgBold.copyWith(
                    color: AppColors.background_black,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                // Start & End Time
                Text(
                  " من ${shift.startTime ?? "--:--"} - إلي ${shift.endTime ?? "--:--"}",
                  style: context.typography.smRegular.copyWith(
                    color: AppColors.textSecondaryParagraph,
                  ),
                ),
              ],
            ),
          ),

          // 🔹 Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Edit
              InkWell(
                onTap: () {
                  Get.delete<CreateShiftViewModel>();
                  showCustomBottomSheet(
                    context: context,
                    child: CreateShiftView(
                      shift: shift,
                      doctor_key: doctor_key,
                      clinic_key: controller.clinic_key ?? "",
                    ),
                  );
                },
                child: Svgicon(
                  icon: IconsConstants.edit_btn,
                  height: 30.h,
                  width: 30.w,
                ),
              ),
              const SizedBox(width: 8),
              // Delete
              InkWell(
                onTap: () => showConfirmBottomSheet(context),
                child: Svgicon(
                  icon: IconsConstants.delete_btn,
                  height: 30.h,
                  width: 30.w,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void showConfirmBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return ConfirmBottomSheet(
          title: "هل أنت متأكد من حذف الوردية؟",
          message: "لن تتمكن من استعادة البيانات بعد الحذف.",
          confirmText: "حذف",
          cancelText: "إلغاء",
          onConfirm: () => _deleteShift(),
        );
      },
    );
  }

  void _deleteShift() {
    controller.deleteShift(shift);
    Loader.showSuccess("تم حذف الوردية بنجاح");
  }
}
