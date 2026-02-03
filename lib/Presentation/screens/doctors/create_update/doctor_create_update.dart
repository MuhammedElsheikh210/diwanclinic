import 'package:diwanclinic/Presentation/screens/doctors/create_update/doctor_create_update_controller.dart';
import '../../../../../index/index_main.dart';

class CreateDoctorView extends StatefulWidget {
  final String specializeKey;
  final String? specializName;
  final LocalUser? doctor;

  const CreateDoctorView({
    Key? key,
    required this.specializeKey,
    this.specializName,
    this.doctor,
  }) : super(key: key);

  @override
  State<CreateDoctorView> createState() => _CreateDoctorViewState();
}

class _CreateDoctorViewState extends State<CreateDoctorView> {
  final HandleKeyboardService keyboardService = HandleKeyboardService();
  final GlobalKey<FormState> globalKeyDoctor = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    final vm = initController(
      () => CreateDoctorViewModel(
        specializeKey: widget.specializeKey,
        specializeName: widget.specializName ?? "",
      ),
    );

    vm.specializationNameController.text =
        widget.doctor?.specializationName ?? widget.specializName ?? "";
    if (widget.doctor != null) {
      vm.nameController.text = widget.doctor?.name ?? "";
      vm.phoneController.text = widget.doctor?.phone ?? "";
      vm.whatsappController.text = widget.doctor?.whatsAppPhone ?? "";
      vm.facebookController.text = widget.doctor?.facebookLink ?? "";
      vm.instagramController.text = widget.doctor?.instagramLink ?? "";
      vm.tiktokController.text = widget.doctor?.tiktokLink ?? "";
      vm.specializationNameController.text =
          widget.doctor?.specializationName ?? widget.specializName ?? "";
      vm.isUpdate = true;
      vm.existingDoctor = widget.doctor;
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
        init: CreateDoctorViewModel(
          specializeKey: widget.specializeKey,
          specializeName: widget.specializName ?? "",
        ),
        builder: (controller) {
          return SingleChildScrollView(
            child: Form(
              key: globalKeyDoctor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🩺 Profile Image Picker
                  GestureDetector(
                    onTap: controller.pickProfileImage,
                    child: Center(
                      child: CircleAvatar(
                        radius: 45.r,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.1,
                        ),
                        backgroundImage: controller.profileImageFile != null
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

                  /// 🏞 Cover Image Picker
                  GestureDetector(
                    onTap: controller.pickCoverImage,
                    child: Container(
                      height: 120.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        color: AppColors.primary.withValues(alpha: 0.05),
                        image: controller.coverImageFile != null
                            ? DecorationImage(
                                fit: BoxFit.cover,
                                image: FileImage(controller.coverImageFile!),
                              )
                            : (widget.doctor?.coverImage != null
                                  ? DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                        widget.doctor!.coverImage!,
                                      ),
                                    )
                                  : null),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.add_photo_alternate,
                          color: AppColors.primary,
                          size: 30.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15.h),

                  CustomInputField(
                    label: "اسم الطبيب",
                    controller: controller.nameController,
                    hintText: "ادخل اسم الطبيب",
                    keyboardType: TextInputType.name,
                    focusNode: FocusNode(),
                    validator: InputValidators.combine([notEmptyValidator]),
                  ),
                  SizedBox(height: 10.h),

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

                  CustomInputField(
                    label: "اسم التخصص",
                    controller: controller.specializationNameController,
                    hintText: "ادخل اسم التخصص",
                    focusNode: FocusNode(),
                    keyboardType: TextInputType.name,
                    validator: InputValidators.combine([notEmptyValidator]),
                  ),
                  SizedBox(height: 10.h),

                  SizedBox(height: 10.h),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 10.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText(
                          text: "السماح بالحجز عن بُعد",
                          textStyle: context.typography.lgBold.copyWith(
                            color: AppColors.textDisplay,
                          ),
                        ),

                        GetBuilder<CreateDoctorViewModel>(
                          builder: (controller) {
                            return Switch(
                              value: controller.remoteReservationAbility == 1,
                              activeColor: AppColors.primary,
                              onChanged: (v) {
                                controller.setRemoteReservationAbility(v);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  CustomInputField(
                    label: "رابط إنستجرام",
                    controller: controller.instagramController,
                    hintText: "https://instagram.com/...",
                    focusNode: FocusNode(),
                    keyboardType: TextInputType.name,
                    validator: InputValidators.combine([]),
                  ),
                  SizedBox(height: 10.h),

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

                  SafeArea(
                    child: BottomNavigationActions(
                      rightTitle: controller.isUpdate
                          ? "تحديث الطبيب"
                          : "إضافة الطبيب",
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
