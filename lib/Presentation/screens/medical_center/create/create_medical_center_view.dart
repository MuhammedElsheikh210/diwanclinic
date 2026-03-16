import 'package:diwanclinic/Presentation/screens/medical_center/create/create_medical_center_view_model.dart';

import '../../../../../index/index_main.dart';

class CreateMedicalCenterView extends StatelessWidget {
  const CreateMedicalCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateMedicalCenterViewModel>(
      init: CreateMedicalCenterViewModel(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            title: Text(
              "إضافة مركز طبي",
              style: context.typography.lgBold.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                /// 🏥 Name
                CustomInputField(
                  label: "اسم المركز",
                  controller: controller.nameController,
                  hintText: "أدخل اسم المركز",
                  focusNode: FocusNode(),
                  keyboardType: TextInputType.name,
                  validator: InputValidators.combine([notEmptyValidator]),
                ),
                SizedBox(height: 14.h),

                /// 📍 Address
                CustomInputField(
                  label: "العنوان",
                  controller: controller.addressController,
                  hintText: "أدخل عنوان المركز",
                  focusNode: FocusNode(),
                  keyboardType: TextInputType.streetAddress,
                  validator: InputValidators.combine([notEmptyValidator]),
                ),
                SizedBox(height: 14.h),

                /// ☎️ Phone
                CustomInputField(
                  label: "رقم الهاتف",
                  controller: controller.phoneController,
                  hintText: "أدخل رقم الهاتف",
                  focusNode: FocusNode(),
                  keyboardType: TextInputType.phone,
                  validator: InputValidators.combine([notEmptyValidator]),
                ),
                SizedBox(height: 30.h),

                /// ➕ Add Button
                PrimaryTextButton(
                  label: AppText(
                    text: "إضافة المركز",
                    textStyle: context.typography.mdMedium,
                  ),
                  onTap: controller.createMedicalCenter,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
