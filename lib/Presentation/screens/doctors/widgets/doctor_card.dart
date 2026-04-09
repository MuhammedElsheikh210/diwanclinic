import '../../../../../index/index_main.dart';

class DoctorCard extends StatelessWidget {
  final LocalUser doctor;
  final DoctorViewModel controller;
  final bool? fromAdmin;

  const DoctorCard({
    super.key,
    required this.doctor,
    required this.controller,
    this.fromAdmin,
  });

  bool get isAdmin {
    final currentUser = LocalUser().getUserData();
    return currentUser.userType?.name == 'admin';
  }

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;

    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap:
          () =>
              fromAdmin == true
                  ? Get.to(
                    () => ClinicView(doctorKey: doctor.uid),
                    binding: Binding(),
                  )
                  : Get.to(() => DoctorDetailsView(doctor: doctor)),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 6.w),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.borderNeutralPrimary, width: 0.7),
          boxShadow: [
            BoxShadow(
              color: AppColors.background_black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 👨‍⚕️ Doctor Avatar
            CircleAvatar(
              radius: 70.r,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              backgroundImage:
                  doctor.profileImage != null && doctor.profileImage!.isNotEmpty
                      ? NetworkImage(doctor.profileImage!)
                      : null,
              child:
                  doctor.profileImage == null || doctor.profileImage!.isEmpty
                      ? Icon(
                        Icons.person_rounded,
                        color: AppColors.primary,
                        size: 30.sp,
                      )
                      : null,
            ),

            SizedBox(width: 12.w),

            // 🩺 Doctor Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // 👨‍⚕️ Doctor Name
                  Text(
                    doctor.name ?? "بدون اسم",
                    style: typography.mdBold.copyWith(
                      color: AppColors.textDisplay,
                      fontSize: 20.sp,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),

                  // 👨‍⚕️ Doctor Name
                  Text(
                    doctor.address ?? "بدون اسم",
                    style: typography.smRegular.copyWith(
                      color: AppColors.textDisplay,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),

                  // ⭐ Rating
                  doctor.totalRate == 0.0
                      ? const SizedBox()
                      : Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: AppColors.yellowForeground,
                              size: 18,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              "${doctor.totalRate?.toStringAsFixed(1) ?? '0.0'} "
                              "(${doctor.numberOfRates ?? 0})",
                              style: typography.smRegular.copyWith(
                                color: AppColors.textSecondaryParagraph,
                              ),
                            ),
                          ],
                        ),
                      ),

                  // 📱 Phone Number
                  if (doctor.phone != null && doctor.phone!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            color: AppColors.primary,
                            size: 16,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            doctor.phone!,
                            style: typography.mdRegular.copyWith(
                              color: AppColors.textSecondaryParagraph,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // 🛠️ Admin actions (Edit/Delete)
            if (isAdmin)
              PopupMenuButton<String>(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                icon: const Icon(Icons.more_vert, color: AppColors.textDisplay),
                onSelected: (value) {
                  if (value == 'edit') {
                    Get.delete<CreateDoctorViewModel>();
                    showCustomBottomSheet(
                      context: context,
                      child: CreateDoctorView(
                        specializeKey: doctor.clinicKey ?? "",
                        doctor: doctor,
                      ),
                    );
                  } else if (value == 'delete') {
                    controller.deleteDoctor(doctor);
                  }
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(value: 'edit', child: Text("تعديل")),
                      const PopupMenuItem(value: 'delete', child: Text("حذف")),
                    ],
              ),
          ],
        ),
      ),
    );
  }
}
