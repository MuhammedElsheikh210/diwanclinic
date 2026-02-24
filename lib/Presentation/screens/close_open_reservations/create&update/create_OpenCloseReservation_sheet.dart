import '../../../../index/index_main.dart';

class CreateOpenclosereservationView extends StatelessWidget {
  final LegacyQueueModel? model;
  final String? shiftKey; // ✅ مهم في حالة التعديل

  const CreateOpenclosereservationView({super.key, this.model, this.shiftKey});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateOpenclosereservationViewModel>(
      init: CreateOpenclosereservationViewModel()
        ..init(model, incomingShiftKey: shiftKey),
      builder: (controller) {
        final bool isClosed = controller.isClosed;

        return Padding(
          padding: EdgeInsets.all(16.w),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🧾 Title
                Center(
                  child: Text(
                    controller.isUpdate ? "تعديل حالة اليوم" : "إضافة يوم",
                    style: context.typography.mdBold,
                  ),
                ),

                SizedBox(height: 24.h),

                /// 📅 Date Picker
                CalenderWidget(
                  hintText: "اختر التاريخ",
                  initialTimestamp: controller.selectedTimestamp,
                  onDateSelected: (timeStamp, date) {
                    controller.setDate(timeStamp);
                  },
                ),

                SizedBox(height: 20.h),

                /// ⏰ Shift Selector
                if (controller.shiftDropdownItems != null &&
                    controller.shiftDropdownItems!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "الفترة",
                        style: context.typography.smMedium.copyWith(
                          color: AppColors.textSecondaryParagraph,
                        ),
                      ),
                      SizedBox(height: 8.h),

                      GestureDetector(
                        onTap: () {
                          if (controller.shiftDropdownItems!.length <= 1) {
                            return; // لو شيفت واحد مفيش داعي تفتح dialog
                          }

                          Get.dialog(
                            ShiftSelectionDialog(
                              shifts: controller.shiftDropdownItems!,
                              initialSelected: controller.selectedShift,
                              onSelect: (shift) {
                                controller.selectedShift = shift;
                                controller.shiftKey = shift.key;
                                controller.update();
                              },
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.borderNeutralPrimary.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.schedule,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  controller.selectedShift?.name ??
                                      "اختر الفترة",
                                  style: context.typography.mdMedium.copyWith(
                                    color: controller.selectedShift == null
                                        ? AppColors.errorForeground
                                        : AppColors.textDisplay,
                                  ),
                                ),
                              ),
                              if (controller.shiftDropdownItems!.length > 1)
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.primary,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                SizedBox(height: 24.h),

                /// 🔒 Status Selection
                Text(
                  "حالة اليوم",
                  style: context.typography.smMedium.copyWith(
                    color: AppColors.textSecondaryParagraph,
                  ),
                ),

                SizedBox(height: 8.h),

                /// ✅ Open
                InkWell(
                  onTap: () {
                    if (isClosed) {
                      controller.toggleClosed(false);
                    }
                  },
                  child: Row(
                    children: [
                      Checkbox(
                        value: !isClosed,
                        onChanged: (value) {
                          if (value == true) {
                            controller.toggleClosed(false);
                          }
                        },
                        activeColor: AppColors.primary,
                      ),
                      Text(
                        "اليوم مفتوح للحجوزات",
                        style: context.typography.mdMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                /// ❌ Closed
                InkWell(
                  onTap: () {
                    if (!isClosed) {
                      controller.toggleClosed(true);
                    }
                  },
                  child: Row(
                    children: [
                      Checkbox(
                        value: isClosed,
                        onChanged: (value) {
                          if (value == true) {
                            controller.toggleClosed(true);
                          }
                        },
                        activeColor: AppColors.errorForeground,
                      ),
                      Text(
                        "اليوم مغلق للحجوزات",
                        style: context.typography.mdMedium.copyWith(
                          color: AppColors.errorForeground,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30.h),

                /// 💾 Save
                PrimaryTextButton(
                  label: AppText(
                    text: "حفظ",
                    textStyle: context.typography.mdMedium,
                  ),
                  onTap: controller.save,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
