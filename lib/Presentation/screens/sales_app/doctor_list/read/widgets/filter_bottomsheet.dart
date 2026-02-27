import '../../../../../../index/index_main.dart';

class FilterBottomSheet extends StatelessWidget {
  final DoctorListViewModel controller;

  const FilterBottomSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(bottom: 20.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          Row(
            children: [
              Text("فلترة الدكاترة", style: context.typography.mdBold),
              const Spacer(),
              if (controller.selectedFilterClass != null ||
                  controller.selectedFilterSpecialization != null)
                InkWell(
                  onTap: controller.clearFilter,
                  child: Text(
                    "إلغاء",
                    style: context.typography.smMedium.copyWith(
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: 20.h),

          DropdownButtonFormField<SpecializationModel>(
            value: controller.selectedFilterSpecialization,
            decoration: _proFilterDecoration(),
            hint: const Text("التخصص"),
            items: controller.specializations
                .map((e) => DropdownMenuItem(value: e, child: Text(e.label)))
                .toList(),
            onChanged: (value) {
              controller.selectedFilterSpecialization = value;
              controller.applyFilter();
            },
          ),

          SizedBox(height: 16.h),

          DropdownButtonFormField<String>(
            value: controller.selectedFilterClass,
            decoration: _proFilterDecoration(),
            hint: const Text("التصنيف"),
            items: controller.doctorClasses
                .map((e) => DropdownMenuItem(value: e, child: Text("Class $e")))
                .toList(),
            onChanged: (value) {
              controller.selectedFilterClass = value;
              controller.applyFilter();
            },
          ),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

InputDecoration _proFilterDecoration() {
  return InputDecoration(
    filled: true,
    fillColor: AppColors.grayLight.withValues(alpha: 0.15),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.r),
      borderSide: BorderSide.none,
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
  );
}
