/// medical_record_static_section.dart

import '../../../../../../index/index_main.dart';

import 'medical_record_date_field.dart';
import 'medical_record_image_picker.dart';
import 'medical_record_input_field.dart';

class MedicalRecordStaticSection extends StatelessWidget {
  final PatientProfileAllHistoryViewModel vm;

  const MedicalRecordStaticSection({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 1,
          color: AppColors.dividerAndLines,
          margin: EdgeInsets.only(bottom: 14.h),
        ),
        MedicalRecordDateField(
          hint: "تاريخ الإعادة",
          controller: vm.revisitDateController,
        ),
        SizedBox(height: 10.h),
        MedicalRecordInputField(
          hint: "ملاحظات",
          controller: vm.notesController,
          maxLines: 3,
          focusNode: vm.keyboardService.getFocusNode(vm.keyboardKeys[40]),
        ),
        SizedBox(height: 12.h),
        MedicalRecordImagePicker(vm: vm),
      ],
    );
  }
}
