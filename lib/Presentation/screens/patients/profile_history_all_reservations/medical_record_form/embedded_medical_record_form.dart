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
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.dividerAndLines),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          /// ✅ Show only if more than one category exists
          if (_shouldShowCategoryDropdown) ...[
            MedicalRecordCategoryDropdown(vm: vm),

            SizedBox(height: 20.h),
          ],

          MedicalRecordDynamicFields(vm: vm),

          SizedBox(height: 16.h),

          MedicalRecordStaticSection(vm: vm),
        ],
      ),
    );
  }
}
