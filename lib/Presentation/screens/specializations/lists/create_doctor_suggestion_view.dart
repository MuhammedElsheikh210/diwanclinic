import 'package:diwanclinic/Presentation/parentControllers/doctor_suggestion_service.dart';

import '../../../../../index/index_main.dart';

class CreateDoctorSuggestionView extends StatefulWidget {
  const CreateDoctorSuggestionView({super.key});

  @override
  State<CreateDoctorSuggestionView> createState() =>
      _CreateDoctorSuggestionViewState();
}

class _CreateDoctorSuggestionViewState
    extends State<CreateDoctorSuggestionView> {
  final _formKey = GlobalKey<FormState>();
  final doctorNameController = TextEditingController();
  final specializationController = TextEditingController();
  final addressController = TextEditingController();

  final DoctorSuggestionService _service = DoctorSuggestionService();

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Text("اقتراح طبيب جديد", style: typography.lgBold),
                  ),
                  SizedBox(height: 20.h),

                  /// 🩺 Doctor Name
                  AppTextField(
                    controller: doctorNameController,
                    hintText: "اسم الطبيب",
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "من فضلك أدخل اسم الطبيب";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10.h),

                  /// 🧠 Specialization Name
                  AppTextField(
                    controller: specializationController,
                    hintText: "اسم التخصص",
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "من فضلك أدخل التخصص";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10.h),

                  /// 🏥 Address (Optional)
                  AppTextField(
                    controller: addressController,
                    hintText: "العنوان (اختياري)",
                  ),
                  SizedBox(height: 20.h),

                  /// ✅ Submit Button
                  SizedBox(
                    width: ScreenUtil().screenWidth,
                    height: 55.h,
                    child: PrimaryTextButton(
                      onTap: () {
                        final user = Get.find<UserSession>().user;

                        if (_formKey.currentState?.validate() ?? false) {
                          final model = DoctorSuggestionModel(
                            key: const Uuid().v4().toString(),
                            patientkey: user?.uid,
                            doctorName: doctorNameController.text.trim(),
                            specializeName:
                                specializationController.text.trim(),
                            address:
                                addressController.text.trim().isEmpty
                                    ? null
                                    : addressController.text.trim(),
                          );

                          _service.addDoctorSuggestionData(
                            suggestion: model,
                            voidCallBack: (status) {
                              if (status == ResponseStatus.success) {
                                Loader.showSuccess("تم إرسال الاقتراح بنجاح");
                                Get.back();
                              } else {
                                Loader.showError("فشل في إرسال الاقتراح");
                              }
                            },
                          );
                        }
                      },
                      label: AppText(
                        text: "إرسال الاقتراح",
                        textStyle: context.typography.mdBold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
