import '../../../../../index/index_main.dart';

import '../../../../../index/index_main.dart';

class CreateDoctorListView extends StatelessWidget {
  final DoctorListModel? doctor;

  const CreateDoctorListView({Key? key, this.doctor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final keyboardService = HandleKeyboardService();
    final formKey = GlobalKey<FormState>();
    final keys = keyboardService.generateKeys('CreateDoctorListView', 3);

    return GetBuilder<CreateDoctorListViewModel>(
      init: CreateDoctorListViewModel(),
      builder: (controller) {
        if (doctor != null && !controller.isUpdate) {
          controller.populateFields(doctor!);
        }

        return Scaffold(
          backgroundColor: AppColors.white,
          body: Column(
            children: [
              /// 🔵 HEADER
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 25.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(30.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      controller.isUpdate
                          ? "تحديث الدكتور"
                          : "إضافة دكتور جديد",
                      style: context.typography.lgBold.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),

              /// 🔹 FORM
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Form(
                    key: formKey,
                    child: ListView(
                      children: [
                        /// 🧑‍⚕️ Doctor Info
                        _buildSectionCard(
                          context: context,
                          title: "بيانات الدكتور",
                          child: CustomInputField(
                            padding_horizontal: 0,
                            label: "اسم الدكتور",
                            hintText: "اكتب اسم الدكتور",
                            controller: controller.nameController,
                            validator: notEmptyValidator,
                            focusNode: keyboardService.getFocusNode(keys[0]),
                            keyboardType: TextInputType.text,
                          ),
                        ),

                        SizedBox(height: 20.h),

                        /// 📚 Classification
                        _buildSectionCard(
                          context: context,
                          title: "التصنيف",
                          child: Column(
                            children: [
                              DropdownButtonFormField<SpecializationModel>(
                                value: controller.selectedSpecialization,
                                decoration: _inputDecoration(),
                                items: controller.specializations
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e.label),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  controller.selectedSpecialization = value;
                                  controller.update();
                                },
                              ),

                              SizedBox(height: 16.h),

                              DropdownButtonFormField<String>(
                                value: controller.selectedDoctorClass,
                                decoration: _inputDecoration(),
                                items: controller.doctorClasses
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text("Class $e"),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  controller.selectedDoctorClass = value;
                                  controller.update();
                                },
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20.h),

                        /// ⏰ Visit Schedule
                        _buildSectionCard(
                          context: context,
                          title: "مواعيد الزيارة",
                          child: CustomInputField(
                            padding_horizontal: 0,
                            label: "المواعيد",
                            hintText: "مثال: من السبت إلى الخميس من 9 إلى 5",
                            controller: controller.visitScheduleController,
                            validator: notEmptyValidator,
                            focusNode: keyboardService.getFocusNode(keys[1]),
                            keyboardType: TextInputType.text,
                          ),
                        ),

                        SizedBox(height: 120.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          /// 🔵 SAVE BUTTON
          bottomNavigationBar: Container(
            padding: EdgeInsets.all(20.w),
            child: PrimaryTextButton(
              appButtonSize: AppButtonSize.xxLarge,
              onTap: controller.saveDoctor,
              customBackgroundColor: controller.validateStep()
                  ? AppColors.primary
                  : AppColors.grayLight,
              label: AppText(
                text: controller.isUpdate ? "تحديث" : "حفظ",
                textStyle: context.typography.mdMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget _buildSectionCard({
  required String title,
  required Widget child,
  required BuildContext context,
}) {
  return Container(
    padding: EdgeInsets.all(18.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.typography.mdBold),
        SizedBox(height: 14.h),
        child,
      ],
    ),
  );
}

InputDecoration _inputDecoration() {
  return InputDecoration(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
    contentPadding: EdgeInsets.symmetric(horizontal: 14.w),
  );
}
