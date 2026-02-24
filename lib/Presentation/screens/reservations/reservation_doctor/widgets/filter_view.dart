import '../../../../../index/index_main.dart';

class FilterViewReservation extends StatelessWidget {
  FilterViewReservation({Key? key}) : super(key: key);

  final ReservationDoctorViewModel controller =
      Get.find<ReservationDoctorViewModel>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReservationDoctorViewModel>(
      builder: (vm) {
        final clinics = vm.clinicDropdownItems ?? [];
        final shifts = vm.shiftDropdownItems ?? [];

        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─────────────────────────────
              // 🔹 Clinic Wrap
              // ─────────────────────────────
              Text("العيادة", style: context.typography.mdMedium),
              SizedBox(height: 12.h),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: clinics.map((clinic) {
                  final isSelected = vm.selectedClinic?.key == clinic.key;

                  return GestureDetector(
                    onTap: () async {
                      if (isSelected) {
                        vm.selectedClinic = null;
                        vm.selectedShift = null;
                      } else {
                        vm.selectedClinic = ClinicModel(
                          key: clinic.key,
                          title: clinic.name,
                        );

                        vm.selectedShift = null;

                        await vm.loadShiftsForClinic(clinic.key!);
                      }

                      vm.update();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey.shade300,
                        ),
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.white,
                      ),
                      child: Text(
                        clinic.name ?? "",
                        style: context.typography.smMedium.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              // ─────────────────────────────
              // 🔹 Shift Wrap
              // ─────────────────────────────
              if (shifts.isNotEmpty) ...[
                SizedBox(height: 25.h),

                Text("الوردية", style: context.typography.mdMedium),
                SizedBox(height: 12.h),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: shifts.map((shift) {
                    final isSelected = vm.selectedShift?.key == shift.key;

                    return GestureDetector(
                      onTap: () {
                        vm.selectedShift = isSelected ? null : shift;
                        vm.update();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey.shade300,
                          ),
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.1)
                              : Colors.white,
                        ),
                        child: Text(
                          shift.name ?? "",
                          style: context.typography.smMedium.copyWith(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              SizedBox(height: 30.h),

              // ─────────────────────────────
              // 🔹 Buttons
              // ─────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: PrimaryTextButton(
                      onTap: () {
                        vm.getReservations(is_filter: false);
                        Get.back();
                      },
                      label: AppText(
                        text: "تطبيق الفلتر",
                        textStyle: context.typography.mdBold.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        vm.selectedClinic = null;
                        vm.selectedShift = null;
                        vm.getReservations();
                        vm.update();
                        Get.back();
                      },
                      child: const Text("مسح الفلتر"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
