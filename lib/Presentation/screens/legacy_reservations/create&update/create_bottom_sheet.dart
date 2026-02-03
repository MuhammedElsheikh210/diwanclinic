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
        return Padding(
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
                onDateSelected: (timeStamp, date) {
                  controller.setDate(timeStamp); // ✅ دلوقتي صح
                },
              ),

              SizedBox(height: 16.h),

              /// 🔢 Value
              CustomInputField(
                label: "عدد الحجوزات",
                controller: controller.valueController,
                keyboardType: TextInputType.number,
                hintText: "مثال: 10",
                focusNode: FocusNode(),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "العدد مطلوب";
                  }
                  return null;
                },
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
        );
      },
    );
  }
}
