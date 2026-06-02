// ignore_for_file: avoid_renaming_method_parameters
import '../../../../../index/index_main.dart';

class CreateClinicView extends StatefulWidget {
  final ClinicModel? clinic;
  final String? doctorKey;

  const CreateClinicView({Key? key, this.clinic, this.doctorKey})
    : super(key: key);

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

    createClinicVM.doctorKey = widget.doctorKey;

    if (widget.clinic != null) {
      createClinicVM.existingClinic = widget.clinic;
      createClinicVM.populateFields(widget.clinic!);
      createClinicVM.is_update = true;
    }

    createClinicVM.update();
  }

  @override
  Widget build(BuildContext context) {
    final keys = keyboardService.generateKeys(
      'CreateClinicView',
      11,
    ); // 🔥 زودنا واحد

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
          bottomNavigationBar: SafeArea(
            top: false,
            child: SizedBox(
              height: 80.h,
              child: BottomNavigationActions(
                rightTitle:
                    controller.is_update ? "تحديث العيادة" : "إضافة العيادة",
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
                    focusNode: keyboardService.getFocusNode(keys[1]),
                    voidCallbackAction: (_) => controller.update(),
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: 12.h),

                  CustomInputField(
                    label: "الهاتف 1",
                    controller: controller.phone1Controller,
                    hintText: "ادخل الهاتف الأول",
                    validator: InputValidators.combine([notEmptyValidator]),
                    focusNode: keyboardService.getFocusNode(keys[2]),
                    voidCallbackAction: (_) => controller.update(),
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 12.h),

                  CustomInputField(
                    label: "العنوان",
                    controller: controller.addressController,
                    hintText: "ادخل عنوان العيادة",
                    validator: InputValidators.combine([notEmptyValidator]),
                    focusNode: keyboardService.getFocusNode(keys[3]),
                    voidCallbackAction: (_) => controller.update(),
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: 12.h),

                  /// 🔹 Location
                  _LocationPickerWidget(controller: controller),
                  SizedBox(height: 12.h),

                  /// 🔹 Prices
                  CustomInputField(
                    label: "سعر الكشف",
                    controller: controller.consultationPriceController,
                    hintText: "ادخل سعر الكشف",
                    validator: InputValidators.combine([notEmptyValidator]),
                    focusNode: keyboardService.getFocusNode(keys[4]),
                    voidCallbackAction: (_) => controller.update(),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 12.h),

                  CustomInputField(
                    label: "سعر الإعادة",
                    controller: controller.followUpPriceController,
                    hintText: "ادخل سعر الإعادة",
                    validator: InputValidators.combine([notEmptyValidator]),
                    focusNode: keyboardService.getFocusNode(keys[5]),
                    voidCallbackAction: (_) => controller.update(),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 12.h),

                  CustomInputField(
                    label: "سعر الكشف المستعجل",
                    controller: controller.urgentConsultationPriceController,
                    hintText: "ادخل سعر الكشف المستعجل",
                    validator: InputValidators.combine([notEmptyValidator]),
                    focusNode: keyboardService.getFocusNode(keys[6]),
                    voidCallbackAction: (_) => controller.update(),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16.h),

                  CustomInputField(
                    label: "سياسة دخول الكشف المستعجل",
                    controller: controller.urgentPolicyController,
                    hintText: "بعد كام كشف عادي",
                    validator: InputValidators.combine([notEmptyValidator]),
                    focusNode: keyboardService.getFocusNode(keys[7]),
                    voidCallbackAction: (_) => controller.update(),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16.h),

                  /// 🔥 max revisit
                  CustomInputField(
                    label: "عدد الإعادات قبل الكشف الجديد",
                    controller: controller.maxRevisitController,
                    hintText: "مثال: 3",
                    validator: InputValidators.combine([notEmptyValidator]),
                    focusNode: keyboardService.getFocusNode(keys[8]),
                    voidCallbackAction: (_) => controller.update(),
                    keyboardType: TextInputType.number,
                  ),

                  SizedBox(height: 12.h),

                  /// 🔥🔥 revisit validity
                  CustomInputField(
                    label: "مدة صلاحية الإعادة (بالأيام)",
                    controller: controller.revisitValidityController,
                    hintText: "مثال: 14",
                    validator: InputValidators.combine([notEmptyValidator]),
                    focusNode: keyboardService.getFocusNode(keys[9]),
                    voidCallbackAction: (_) => controller.update(),
                    keyboardType: TextInputType.number,
                  ),

                  SizedBox(height: 12.h),

                  /// 🔥 Pediatric
                  SwitchListTile(
                    title: Text(
                      "عيادة أطفال؟",
                      style: context.typography.smMedium,
                    ),
                    subtitle: Text(
                      "يتيح ضبط ترتيب دخول حديثي الولادة",
                      style: context.typography.xsRegular.copyWith(
                        color: AppColors.textSecondaryParagraph,
                      ),
                    ),
                    value: controller.isPediatric,
                    onChanged: (val) {
                      controller.isPediatric = val;
                      controller.update();
                    },
                    activeColor: AppColors.primary,
                  ),

                  if (controller.isPediatric) ...[
                    SizedBox(height: 8.h),
                    CustomInputField(
                      label: "حديث الولادة يدخل بعد كام حالة",
                      controller: controller.newbornSlotGapController,
                      hintText: "مثال: 2",
                      validator: InputValidators.combine([notEmptyValidator]),
                      focusNode: keyboardService.getFocusNode(keys[10]),
                      voidCallbackAction: (_) => controller.update(),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 12.h),
                  ],

                  /// 🔹 Deposit
                  SwitchListTile(
                    title: Text(
                      "هل الحجز بعربون؟",
                      style: context.typography.smMedium,
                    ),
                    value: controller.reserveWithDeposit == 1,
                    onChanged: (val) {
                      controller.reserveWithDeposit = val ? 1 : 0;
                      controller.update();
                    },
                    activeColor: AppColors.primary,
                  ),

                  if (controller.reserveWithDeposit == 1) ...[
                    CustomInputField(
                      label: "النسبة المئوية للعربون %",
                      controller: controller.depositPercentController,
                      hintText: "ادخل النسبة",
                      validator: InputValidators.combine([notEmptyValidator]),
                      focusNode: keyboardService.getFocusNode(keys[9]),
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

class _LocationPickerWidget extends StatelessWidget {
  final CreateClinicViewModel controller;
  const _LocationPickerWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    final hasLocation =
        controller.selectedLatitude != null && controller.selectedLongitude != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderNeutralPrimary),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            hasLocation ? Icons.location_on : Icons.location_off,
            color: hasLocation ? AppColors.primary : AppColors.textSecondaryParagraph,
            size: 22,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hasLocation
                  ? "الموقع: ${controller.selectedLatitude!.toStringAsFixed(5)}, ${controller.selectedLongitude!.toStringAsFixed(5)}"
                  : "لم يتم تحديد الموقع بعد",
              style: context.typography.smRegular.copyWith(
                color: hasLocation
                    ? AppColors.textDefault
                    : AppColors.textSecondaryParagraph,
              ),
            ),
          ),
          const SizedBox(width: 8),
          controller.isLoadingLocation
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : TextButton.icon(
                  onPressed: controller.fetchCurrentLocation,
                  icon: const Icon(Icons.my_location, size: 18),
                  label: Text(hasLocation ? "تحديث" : "تحديد موقعي"),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
        ],
      ),
    );
  }
}
