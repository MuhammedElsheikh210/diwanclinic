import 'package:diwanclinic/Presentation/screens/Authentication/sign_up%20/SignUpViewModel.dart';

import '../../../../index/index_main.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  late SignUpViewModel controller;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    controller = initController(() => SignUpViewModel());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;
    final keyboardService = HandleKeyboardService();
    final keys = keyboardService.generateKeys("signup", 4);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: KeyboardActions(
          config: keyboardService.buildConfig(context, keys),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40.h),

                  // Logo
                  Center(
                    child: Image.asset(
                      Images.splash,
                      width: 150.w,
                      height: 150.h,
                    ),
                  ),
                  SizedBox(height: 20.h),

                  Center(
                    child: AppText(
                      text: "إنشاء حساب جديد",
                      textStyle: typography.xlBold.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  SizedBox(height: 30.h),

                  // NAME
                  AppTextField(
                    controller: controller.nameController,
                    focusNode: keyboardService.getFocusNode(keys[0]),
                    hintText: "الاسم بالكامل",
                    textInputAction: TextInputAction.next,
                    onChanged: controller.validateName,
                    validator: (v) => (v == null || v.trim().length < 3)
                        ? "الاسم غير صالح"
                        : null,
                  ),
                  SizedBox(height: 20.h),

                  // PHONE
                  AppTextField(
                    controller: controller.phoneController,
                    focusNode: keyboardService.getFocusNode(keys[1]),
                    hintText: "رقم الهاتف",
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    onChanged: controller.validatePhone,
                    validator: (v) => (v == null || v.trim().length < 8)
                        ? "رقم الهاتف غير صحيح"
                        : null,
                  ),
                  SizedBox(height: 20.h),
                  // PASSWORD
                  AppTextField(
                    controller: controller.passwordController,
                    focusNode: keyboardService.getFocusNode(keys[2]),
                    hintText: "كلمة المرور",
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    onChanged: controller.validatePassword,
                    validator: (v) => (v == null || v.length < 6)
                        ? "كلمة المرور يجب أن تكون 6 أحرف على الأقل"
                        : null,
                  ),
                  SizedBox(height: 20.h),


                  // ADDRESS
                  AppTextField(
                    controller: controller.addressController,
                    focusNode: keyboardService.getFocusNode(keys[3]),
                    hintText: "العنوان",
                    maxLines: 2,
                    onChanged: controller.validateAddress,
                    validator: (v) => (v == null || v.trim().length < 5)
                        ? "العنوان غير صالح"
                        : null,
                  ),

                  SizedBox(height: 8.h),

                  // Address NOTE
                  AppText(
                    text: "العنوان ضروري لتوصيل الدواء والحصول على الخصم",
                    textStyle: typography.smRegular.copyWith(
                      color: AppColors.textSecondaryParagraph,
                    ),
                  ),

                  SizedBox(height: 36.h),

                  // SIGN UP BUTTON
                  Obx(() {
                    final ready =
                        controller.isNameValid.value &&
                            controller.isPhoneValid.value &&
                            controller.isPasswordValid.value &&
                            controller.isAddressValid.value;


                    return SizedBox(
                      width: ScreenUtil().screenWidth,
                      child: PrimaryTextButton(
                        appButtonSize: AppButtonSize.xxLarge,
                        label: AppText(
                          text: "إنشاء حساب",
                          textStyle: typography.mdBold.copyWith(
                            color: ready
                                ? AppColors.white
                                : AppColors.grayLight,
                          ),
                        ),
                        onTap: ready
                            ? () {
                                if (_formKey.currentState!.validate()) {
                                  controller.signUp();
                                }
                              }
                            : null,
                      ),
                    );
                  }),

                  SizedBox(height: 20.h),

                  // Back to login
                  Center(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: AppText(
                        text: "رجوع لتسجيل الدخول",
                        textStyle: typography.mdMedium.copyWith(
                          color: AppColors.secondary80,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
