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
    return Container(
      padding: EdgeInsets.all(16.w),

      decoration: BoxDecoration(
        color: AppColors.background_neutral_100,
        borderRadius: BorderRadius.circular(16.r),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          /// =========================
          /// REVISIT DATE
          /// =========================
          MedicalRecordDateField(
            hint: "تاريخ الإعادة",

            controller: vm.revisitDateController,
          ),

          SizedBox(height: 12.h),

          /// =========================
          /// NOTES
          /// =========================
          MedicalRecordInputField(
            hint: "ملاحظات",

            controller: vm.notesController,

            maxLines: 3,

            focusNode: vm.keyboardService.getFocusNode(vm.keyboardKeys[40]),
          ),

          SizedBox(height: 16.h),

          /// =========================
          /// IMAGES
          /// =========================
          MedicalRecordImagePicker(vm: vm),
        ],
      ),
    );
  }
}
