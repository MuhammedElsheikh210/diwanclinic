import '../../../../../index/index_main.dart';

class FilterViewReservation extends StatelessWidget {
  FilterViewReservation({super.key});

  final ReservationDoctorViewModel controller =
      Get.find<ReservationDoctorViewModel>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReservationDoctorViewModel>(
      builder: (vm) {
        final clinics = vm.clinicDropdownItems ?? [];
        final shifts = vm.shiftDropdownItems ?? [];

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.04),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),

          child: SafeArea(
            top: false,

            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // ─────────────────────────────
                // 🔥 Header
                // ─────────────────────────────
                Center(
                  child: Container(
                    width: 45.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: AppColors.borderNeutralPrimary,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),

                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(.08),

                        borderRadius: BorderRadius.circular(14.r),
                      ),

                      child: Icon(
                        Icons.tune_rounded,
                        color: AppColors.primary,
                        size: 24.sp,
                      ),
                    ),

                    SizedBox(width: 12.w),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            "فلترة الحجوزات",

                            style: context.typography.lgBold,
                          ),

                          SizedBox(height: 2.h),

                          Text(
                            "حدد العيادة والفترة لعرض النتائج",

                            style: context.typography.smRegular.copyWith(
                              color: AppColors.textSecondaryParagraph,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 28.h),

                // ─────────────────────────────
                // 🏥 Clinics
                // ─────────────────────────────
                _sectionTitle(
                  context,
                  title: "العيادة",
                  icon: Icons.local_hospital_rounded,
                ),

                SizedBox(height: 14.h),

                Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,

                  children:
                      clinics.map((clinic) {
                        final isSelected = vm.selectedClinic?.key == clinic.key;

                        return _modernChip(
                          context,
                          title: clinic.name ?? "",
                          isSelected: isSelected,

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
                        );
                      }).toList(),
                ),

                // ─────────────────────────────
                // ⏰ Shifts
                // ─────────────────────────────
                if (shifts.isNotEmpty) ...[
                  SizedBox(height: 28.h),

                  _sectionTitle(
                    context,
                    title: "الفترة",
                    icon: Icons.schedule_rounded,
                  ),

                  SizedBox(height: 14.h),

                  Wrap(
                    spacing: 10.w,
                    runSpacing: 10.h,

                    children:
                        shifts.map((shift) {
                          final isSelected = vm.selectedShift?.key == shift.key;

                          return _modernChip(
                            context,
                            title: shift.name ?? "",
                            isSelected: isSelected,

                            onTap: () {
                              vm.selectedShift = isSelected ? null : shift;

                              vm.update();
                            },
                          );
                        }).toList(),
                  ),
                ],

                SizedBox(height: 35.h),

                // ─────────────────────────────
                // 🔥 Buttons
                // ─────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 54.h,

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
                    ),

                    SizedBox(width: 12.w),

                    Expanded(
                      child: SizedBox(
                        height: 54.h,

                        child: OutlinedButton(
                          onPressed: () {
                            vm.selectedClinic = null;

                            vm.selectedShift = null;

                            vm.getReservations();

                            vm.update();

                            Get.back();
                          },

                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: AppColors.primary.withOpacity(.2),
                            ),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.r),
                            ),

                            backgroundColor: AppColors.primary.withOpacity(.03),
                          ),

                          child: Text(
                            "مسح الفلاتر",

                            style: context.typography.mdMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────
  // 🔥 Section Title
  // ─────────────────────────────

  Widget _sectionTitle(
    BuildContext context, {
    required String title,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),

          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(.08),

            borderRadius: BorderRadius.circular(12.r),
          ),

          child: Icon(icon, size: 18.sp, color: AppColors.primary),
        ),

        SizedBox(width: 10.w),

        Text(title, style: context.typography.mdBold),
      ],
    );
  }

  // ─────────────────────────────
  // 🔥 Modern Filter Chip
  // ─────────────────────────────

  Widget _modernChip(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),

        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),

        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.grayLight,

          borderRadius: BorderRadius.circular(16.r),

          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grayLight,
          ),

          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(.18),

                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                  : [],
        ),

        child: Row(
          mainAxisSize: MainAxisSize.min,

          children: [
            if (isSelected) ...[
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.white,
                size: 18.sp,
              ),

              SizedBox(width: 6.w),
            ],

            Text(
              title,

              style: context.typography.smMedium.copyWith(
                color: isSelected ? AppColors.white : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
