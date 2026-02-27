import '../../../../../../index/index_main.dart';

class DoctorListCard extends StatelessWidget {
  final DoctorListModel doctor;
  final DoctorListViewModel controller;

  const DoctorListCard({
    super.key,
    required this.doctor,
    required this.controller,
  });

  Color get classColor {
    switch (doctor.doctorClass) {
      case "A":
        return Colors.green;
      case "B":
        return Colors.orange;
      case "C":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.grayLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 Name + Class + Actions
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name ?? "بدون اسم",
                      style: typography.mdBold.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      SpecializationMapper.getLabel(doctor.specialization),
                      style: typography.smRegular.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              /// 🔥 Popup Menu
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == "edit") {
                    _editDoctor(context);
                  } else if (value == "delete") {
                    _deleteDoctor(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: "edit",
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text("تعديل"),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: "delete",
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text("حذف", style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 12.h),

          /// Class Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: classColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              "Class ${doctor.doctorClass ?? "-"}",
              style: TextStyle(
                color: classColor,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
          ),

          SizedBox(height: 12.h),

          /// Schedule
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  doctor.visitSchedule ?? "لم يتم تحديد المواعيد",
                  style: typography.smRegular,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _editDoctor(BuildContext context) {
    showCustomBottomSheet(
      context: context,
      heightFactor: 0.9,
      child: CreateDoctorListView(doctor: doctor),
    );
  }

  void _deleteDoctor(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("تأكيد الحذف"),
        content: const Text("هل أنت متأكد من حذف هذا الدكتور؟"),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("إلغاء")),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteDoctor(doctor);
            },
            child: const Text("حذف", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
