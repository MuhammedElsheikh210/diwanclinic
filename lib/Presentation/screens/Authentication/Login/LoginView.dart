import 'package:diwanclinic/Presentation/screens/Authentication/sign_up%20/SignUpView.dart';

import '../../../../index/index_main.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final LoginViewModel controller;
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();

  @override
  void initState() {
    controller = initController(() => LoginViewModel());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final HandleKeyboardService keyboardService = HandleKeyboardService();
    final keys = keyboardService.generateKeys('login', 2);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: KeyboardActions(
            config: keyboardService.buildConfig(context, keys),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Form(
                key: _globalKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 40.h),

                    // 🔹 Logo (centered + clean)
                    Center(
                      child: Image.asset(
                        Images.splash,
                        width: 180.w,
                        height: 180.h,
                        fit: BoxFit.contain,
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // 🔹 Welcome Title
                    Center(
                      child: AppText(
                        text: "تسجيل الدخول".tr,
                        textStyle: context.typography.xlBold.copyWith(
                          color: AppColors.primary,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    Center(
                      child: AppText(
                        text: "ادخل رقم الهاتف وكلمة المرور للاستمرار".tr,
                        textStyle: context.typography.smRegular.copyWith(
                          color: AppColors.textSecondaryParagraph,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(height: 40.h),

                    // 🔹 Phone Field
                    AppTextField(
                      controller: controller.textEditingController,
                      focusNode: keyboardService.getFocusNode(keys[0]),
                      hintText: "رقم الهاتف",
                      maxLines: 1,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      onChanged: controller.validatePhone,
                      validator: InputValidators.combine([
                        notEmptyValidator,
                        (v) => (v!.length < 8) ? "رقم الهاتف غير صحيح" : null,
                      ]),
                    ),

                    SizedBox(height: 20.h),

                    // 🔹 Password Field
                    GetBuilder<LoginViewModel>(
                      init: LoginViewModel(),
                      builder: (controller) {
                        return AppTextField(
                          controller: controller.textEditingControllerPassword,
                          focusNode: keyboardService.getFocusNode(keys[1]),
                          hintText: "كلمة المرور",
                          maxLines: 1,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          obscureText: controller.showPassword.value,
                          onChanged: controller.validatePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.showPassword.value
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AppColors.textDefault,
                            ),
                            onPressed: () {
                              controller.togglePasswordVisibility();
                              controller.update();
                            },
                          ),
                          validator: InputValidators.combine([
                            notEmptyValidator,
                            (v) => InputValidators.minLength(
                              v,
                              6,
                              errorMessage: "كلمة المرور يجب ألا تقل عن ٦ أحرف",
                            ),
                          ]),
                        );
                      },
                    ),

                    SizedBox(height: 36.h),

                    // 🔹 Login Button
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        child: PrimaryTextButton(
                          appButtonSize: AppButtonSize.xxLarge,
                          label: AppText(
                            text: "تسجيل الدخول".tr,
                            textStyle: context.typography.mdBold.copyWith(
                              color:
                                  (controller.isPhoneValid.value &&
                                      controller.isPasswordValid.value)
                                  ? AppColors.white
                                  : AppColors.grayLight,
                            ),
                          ),
                          onTap:
                              (controller.isPhoneValid.value &&
                                  controller.isPasswordValid.value)
                              ? () {
                                  FocusScope.of(context).unfocus();
                                  controller.loginData();
                                }
                              : null,
                        ),
                      ),
                    ),

                    SizedBox(height: 25.h),

                    // 🔹 Sign Up Link
                    Center(
                      child: GestureDetector(
                        onTap: () => Get.to(() => const SignUpView()),
                        child: AppText(
                          text: "ليس لديك حساب؟ إنشاء حساب",
                          textStyle: context.typography.mdMedium.copyWith(
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primary,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // 🔹 Help Center Link
                    Center(
                      child: GestureDetector(
                        onTap: () => Get.toNamed(helpCenterView),
                        child: AppText(
                          text: "مركز المساعدة".tr,
                          textStyle: context.typography.mdMedium.copyWith(
                            color: AppColors.secondary80,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.secondary80,
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
      ),
    );
  }
}
