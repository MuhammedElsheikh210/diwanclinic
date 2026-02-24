import 'package:intl/intl.dart';
import '../../../../index/index_main.dart';

class CreateLegacyQueueView extends StatelessWidget {
  final LegacyQueueModel? model;

  const CreateLegacyQueueView({super.key, this.model});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateLegacyQueueViewModel>(
      init: CreateLegacyQueueViewModel()..init(model),
      builder: (controller) {
        return Form(
          key: controller.formKey,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  controller.isUpdate ? "تعديل اليوم" : "إضافة يوم",
                  style: context.typography.mdBold,
                ),

                SizedBox(height: 16.h),

                CalenderWidget(
                  hintText: "اختر التاريخ",
                  initialTimestamp: controller.selectedTimestamp,
                  onDateSelected: (timestamp, date) {
                    controller.setDate(timestamp);
                  },
                ),

                SizedBox(height: 16.h),

                /// 🔢 Value
                CustomInputField(
                  label: "عدد الحجوزات",
                  controller: controller.valueController,
                  keyboardType: TextInputType.number,
                  hintText: "مثال: 10",
                  focusNode: controller.valueFocusNode,
                  validator: controller.validateValue,
                ),

                SizedBox(height: 20.h),

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