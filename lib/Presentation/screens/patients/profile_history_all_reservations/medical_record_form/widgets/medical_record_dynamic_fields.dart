/// medical_record_dynamic_fields.dart

import '../../../../../../index/index_main.dart';

import 'medical_record_date_field.dart';
import 'medical_record_input_field.dart';

class MedicalRecordDynamicFields extends StatelessWidget {
  final PatientProfileAllHistoryViewModel vm;

  const MedicalRecordDynamicFields({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.properties.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 30.h),

          child: Text(
            vm.selectedCategory == null
                ? "اختر تصنيف لعرض الخصائص"
                : "لا توجد خصائص",

            style: context.typography.mdRegular,
          ),
        ),
      );
    }

    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,

      children:
          vm.properties.asMap().entries.map((entry) {
            final index = entry.key;

            final property = entry.value;

            if (property == null) {
              return const SizedBox();
            }

            final controller =
                vm.getPropertyController(property.key) ??
                TextEditingController();

            return SizedBox(
              width: 160.w,

              child: switch (property.type) {
                "date" => MedicalRecordDateField(
                  hint: property.label ?? "",
                  controller: controller,
                ),

                "number" => MedicalRecordInputField(
                  hint: property.label ?? "",
                  controller: controller,
                  keyboardType: TextInputType.number,

                  focusNode: vm.keyboardService.getFocusNode(
                    vm.keyboardKeys[index],
                  ),
                ),

                _ => MedicalRecordInputField(
                  hint: property.label ?? "",
                  controller: controller,

                  focusNode: vm.keyboardService.getFocusNode(
                    vm.keyboardKeys[index],
                  ),
                ),
              },
            );
          }).toList(),
    );
  }
}
