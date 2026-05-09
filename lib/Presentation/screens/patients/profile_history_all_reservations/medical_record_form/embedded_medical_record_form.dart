/// embedded_medical_record_form.dart

import '../../../../../../index/index_main.dart';

class EmbeddedMedicalRecordForm extends StatelessWidget {
  final PatientProfileAllHistoryViewModel vm;

  const EmbeddedMedicalRecordForm({super.key, required this.vm});

  bool get _shouldShowCategoryDropdown {
    return vm.medicalCategories.length > 1;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),

      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),

        border: Border.all(color: AppColors.borderNeutralPrimary),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          /// ✅ Show only if more than one category exists
          if (_shouldShowCategoryDropdown) ...[
            MedicalRecordCategoryDropdown(vm: vm),

            SizedBox(height: 20.h),
          ],

          /// ✅ Dynamic Fields
          MedicalRecordDynamicFields(vm: vm),

          SizedBox(height: 24.h),

          /// ✅ Static Fields
          MedicalRecordStaticSection(vm: vm),
        ],
      ),
    );
  }
}
