import '../../../../index/index_main.dart';

class CreateOpenclosereservationView extends StatelessWidget {
  final LegacyQueueModel? model;

  const CreateOpenclosereservationView({super.key, this.model});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateOpenclosereservationViewModel>(
      init: CreateOpenclosereservationViewModel()..init(model),
      builder: (controller) {
        final bool isClosed = controller.isClosed;

        return Padding(
          padding: EdgeInsets.all(16.w),
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

              SizedBox(height: 20.h),

              /// 📅 Date Picker
              CalenderWidget(
                hintText: "اختر التاريخ",
                initialTimestamp: controller.selectedTimestamp,
                onDateSelected: (timeStamp, date) {
                  controller.setDate(timeStamp);
                },
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

              SizedBox(height: 28.h),

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
        );
      },
    );
  }
}
