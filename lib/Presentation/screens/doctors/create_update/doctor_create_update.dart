import '../../../../../index/index_main.dart';

class CreateDoctorView extends StatefulWidget {
  final String specializeKey;
  final String? specializName;
  final LocalUser? doctor;
  final String? medicalCenterKey;

  const CreateDoctorView({
    Key? key,
    required this.specializeKey,
    this.specializName,
    this.doctor,
    this.medicalCenterKey,
  }) : super(key: key);

  @override
  State<CreateDoctorView> createState() => _CreateDoctorViewState();
}

class _CreateDoctorViewState extends State<CreateDoctorView> {
  final GlobalKey<FormState> globalKeyDoctor = GlobalKey<FormState>();

  late final CreateDoctorViewModel vm;

  @override
  void initState() {
    super.initState();

    vm = initController(
          () => CreateDoctorViewModel(
        specializeKey: widget.specializeKey,
        specializeName: widget.specializName ?? "",
        medicalCenterKey: widget.medicalCenterKey,
      ),
    );

    final doctor = widget.doctor;

    if (doctor != null && doctor.isDoctor) {
      final d = doctor.asDoctor;

      if (d == null) return;

      vm.nameController.text = d.name ?? "";
      vm.phoneController.text = d.phone ?? "";
      vm.qualificationsController.text = d.doctorQualifications ?? "";

      vm.whatsappController.text = d.phone ?? ""; // لو مفيش field منفصل

      vm.facebookController.text = d.facebookLink ?? "";
      vm.instagramController.text = d.instagramLink ?? "";
      vm.tiktokController.text = d.tiktokLink ?? "";

      // ✅ NEW
      vm.remoteReservationAbility = d.remoteReservationAbility;

      vm.isUpdate = true;
      vm.existingDoctor = doctor;

      vm.update();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: Text(
          "إضافة طبيب",
          style: context.typography.lgBold.copyWith(color: AppColors.primary),
        ),
      ),
      body: GetBuilder<CreateDoctorViewModel>(
        builder: (controller) {
          return SingleChildScrollView(
            child: Form(
              key: globalKeyDoctor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🩺 Profile Image
                  GestureDetector(
                    onTap: controller.pickProfileImage,
                    child: Center(
                      child: CircleAvatar(
                        radius: 45.r,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.1,
                        ),
                        backgroundImage:
                            controller.profileImageFile != null
                                ? FileImage(controller.profileImageFile!)
                                : (widget.doctor?.profileImage != null
                                    ? NetworkImage(widget.doctor!.profileImage!)
                                    : null),
                        child:
                            controller.profileImageFile == null &&
                                    widget.doctor?.profileImage == null
                                ? const Icon(
                                  Icons.camera_alt,
                                  color: AppColors.primary,
                                )
                                : null,
                      ),
                    ),
                  ),
                  SizedBox(height: 15.h),

                  /// 👨‍⚕️ Name
                  CustomInputField(
                    label: "اسم الطبيب",
                    controller: controller.nameController,
                    hintText: "ادخل اسم الطبيب",
                    keyboardType: TextInputType.name,
                    focusNode: FocusNode(),
                    validator: InputValidators.combine([notEmptyValidator]),
                  ),
                  SizedBox(height: 10.h),

                  /// 📱 Phone
                  CustomInputField(
                    label: "رقم الهاتف",
                    controller: controller.phoneController,
                    hintText: "ادخل رقم الهاتف",
                    focusNode: FocusNode(),
                    keyboardType: TextInputType.phone,
                    validator: InputValidators.combine([notEmptyValidator]),
                  ),
                  SizedBox(height: 10.h),

                  CustomInputField(
                    label: "رقم الواتساب",
                    controller: controller.whatsappController,
                    hintText: "ادخل رقم الواتساب",
                    keyboardType: TextInputType.phone,
                    focusNode: FocusNode(),
                    validator: InputValidators.combine([notEmptyValidator]),
                  ),
                  SizedBox(height: 10.h),

                  /// 🧠 Specialization Dropdown
                  if (controller.specializations != null)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: DropdownButtonFormField<CategoryEntity>(
                        value: controller.selectedSpecialization,
                        decoration: const InputDecoration(
                          labelText: "اختر التخصص",
                        ),
                        items:
                            controller.specializations!
                                .where((e) => e != null)
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e!.name ?? ""),
                                  ),
                                )
                                .toList(),
                        onChanged: controller.selectSpecialization,
                      ),
                    ),

                  SizedBox(height: 20.h),

                  /// 📜 Qualifications
                  CustomInputField(
                    label: "المؤهلات",
                    controller: controller.qualificationsController,
                    hintText: "المؤهلات",
                    focusNode: FocusNode(),
                    keyboardType: TextInputType.name,
                    validator: InputValidators.combine([]),
                  ),

                  SizedBox(height: 20.h),

                  CustomInputField(
                    label: "رابط إنستجرام",
                    controller: controller.instagramController,
                    hintText: "https://instagram.com/...",
                    focusNode: FocusNode(),
                    keyboardType: TextInputType.name,
                    validator: InputValidators.combine([]),
                  ),
                  SizedBox(height: 20.h),

                  CustomInputField(
                    label: "رابط فيسبوك",
                    controller: controller.facebookController,
                    hintText: "https://facebook.com/...",
                    focusNode: FocusNode(),
                    keyboardType: TextInputType.name,
                    validator: InputValidators.combine([]),
                  ),
                  SizedBox(height: 10.h),

                  CustomInputField(
                    label: "رابط تيك توك",
                    controller: controller.tiktokController,
                    hintText: "https://tiktok.com/@...",
                    focusNode: FocusNode(),
                    keyboardType: TextInputType.name,
                    validator: InputValidators.combine([]),
                  ),
                  SizedBox(height: 20.h),

                  /// ✅ Save Button
                  SafeArea(
                    child: BottomNavigationActions(
                      rightTitle:
                          controller.isUpdate ? "تحديث الطبيب" : "إضافة الطبيب",
                      rightAction: () {
                        if (globalKeyDoctor.currentState?.validate() ?? false) {
                          controller.saveDoctor();
                        }
                      },
                      isRightEnabled: controller.validateStep(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
