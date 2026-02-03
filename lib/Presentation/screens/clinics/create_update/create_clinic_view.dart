import '../../../../../index/index_main.dart';

class CreateClinicView extends StatefulWidget {
  final ClinicModel? clinic;

  const CreateClinicView({Key? key, this.clinic}) : super(key: key);

  @override
  State<CreateClinicView> createState() => _CreateClinicViewState();
}

class _CreateClinicViewState extends State<CreateClinicView> {
  final HandleKeyboardService keyboardService = HandleKeyboardService();
  final GlobalKey<FormState> globalKeyClinic = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final createClinicVM = initController(() => CreateClinicViewModel());

    if (widget.clinic != null) {
      createClinicVM.existingClinic = widget.clinic;
      createClinicVM.populateFields(widget.clinic!);
      createClinicVM.is_update = true;
    }

    createClinicVM.update();
  }

  @override
  Widget build(BuildContext context) {
    final keys = keyboardService.generateKeys('CreateClinicView', 9);

    return GetBuilder<CreateClinicViewModel>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            title: Text(
              controller.is_update ? "تحديث عيادة" : "إضافة عيادة جديدة",
              style: context.typography.lgBold.copyWith(color: AppColors.white),
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(color: AppColors.white),
          ),
          bottomNavigationBar:
              /// 🔹 Save Button
              SafeArea(
                top: false,
                child: SizedBox(
                  height: 80.h,
                  child: BottomNavigationActions(
                    rightTitle: controller.is_update
                        ? "تحديث العيادة"
                        : "إضافة العيادة",
                    rightAction: controller.saveClinic,
                    isRightEnabled: controller.validateStep(),
                  ),
                ),
              ),
          body: Form(
            key: globalKeyClinic,
            child: KeyboardActions(
              config: keyboardService.buildConfig(context, keys),

              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 15,
                ),
                children: [
                  CustomInputField(
                    label: "اسم العيادة",
                    controller: controller.titleController,
                    hintText: "ادخل اسم العيادة",
                    validator: InputValidators.combine([notEmptyValidator]),
                    focusNode: keyboardService.getFocusNode(keys[0]),
                    voidCallbackAction: (_) => controller.update(),
                    keyboardType: TextInputType.name,
                  ),
                  SizedBox(height: 12.h),

                  CustomInputField(
                    label: "أيام العمل",
                    controller: controller.dailyWorksController,
                    hintText: "مثال: من السبت إلى الخميس",
                    validator: InputValidators.combine([notEmptyValidator]),
                    focusNode: keyboardService.getFocusNode(keys[7]),
                    voidCallbackAction: (_) => controller.update(),
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: 12.h),

                  CustomInputField(
                    label: "الهاتف 1",
                    controller: controller.phone1Controller,
                    hintText: "ادخل الهاتف الأول",
                    validator: InputValidators.combine([notEmptyValidator]),
                    focusNode: keyboardService.getFocusNode(keys[1]),
                    voidCallbackAction: (_) => controller.update(),

                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 12.h),

                  CustomInputField(
                    label: "العنوان",
                    controller: controller.addressController,
                    hintText: "ادخل عنوان العيادة",
                    validator: InputValidators.combine([notEmptyValidator]),
                    focusNode: keyboardService.getFocusNode(keys[2]),
                    voidCallbackAction: (_) => controller.update(),

                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: 12.h),

                  /// 🔹 Consultation Prices
                  CustomInputField(
                    label: "سعر الكشف",
                    controller: controller.consultationPriceController,
                    hintText: "ادخل سعر الكشف",
                    validator: InputValidators.combine([notEmptyValidator]),
                    voidCallbackAction: (_) => controller.update(),

                    focusNode: keyboardService.getFocusNode(keys[3]),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 12.h),

                  CustomInputField(
                    label: "سعر الإعادة",
                    controller: controller.followUpPriceController,
                    hintText: "ادخل سعر الإعادة",
                    validator: InputValidators.combine([notEmptyValidator]),
                    voidCallbackAction: (_) => controller.update(),

                    focusNode: keyboardService.getFocusNode(keys[4]),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 12.h),

                  CustomInputField(
                    label: "سعر الكشف المستعجل",
                    controller: controller.urgentConsultationPriceController,

                    hintText: "ادخل سعر الكشف المستعجل",
                    validator: InputValidators.combine([notEmptyValidator]),
                    focusNode: keyboardService.getFocusNode(keys[5]),
                    voidCallbackAction: (_) => controller.update(),

                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16.h),

                  CustomInputField(
                    label: "سياسة دخول الكشف المستعجل",
                    controller: controller.urgentPolicyController,
                    hintText: "بعد كام كشف عادي",
                    validator: InputValidators.combine([notEmptyValidator]),
                    focusNode: keyboardService.getFocusNode(keys[6]),
                    voidCallbackAction: (_) => controller.update(),

                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16.h),

                  /// 🔹 Deposit Toggle
                  SwitchListTile(
                    title: Text(
                      "هل الحجز بعربون؟",
                      style: context.typography.smMedium,
                    ),
                    value: controller.reserveWithDeposit == 0 ? false : true,
                    onChanged: (val) {
                      controller.reserveWithDeposit = val == true ? 1 : 0;
                      controller.update();
                    },
                    activeColor: AppColors.primary,
                  ),

                  if (controller.reserveWithDeposit == 1) ...[
                    CustomInputField(
                      label: "النسبة المئوية للعربون %",
                      controller: controller.depositPercentController,
                      hintText: "ادخل النسبة المئوية للعربون",
                      validator: InputValidators.combine([notEmptyValidator]),
                      focusNode: keyboardService.getFocusNode(keys[6]),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 12.h),
                  ],

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
