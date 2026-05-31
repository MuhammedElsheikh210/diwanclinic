import '../../../../../index/index_main.dart';

class CreatePharmacyView extends StatefulWidget {
  final LocalUser? pharmacy; // ✅ Pharmacy user passed if editing

  /// When non-null → creating a new STAFF account for this pharmacy
  final String? parentPharmacyId;

  const CreatePharmacyView({
    Key? key,
    this.pharmacy,
    this.parentPharmacyId,
  }) : super(key: key);

  @override
  State<CreatePharmacyView> createState() => _CreatePharmacyViewState();
}

class _CreatePharmacyViewState extends State<CreatePharmacyView> {
  final HandleKeyboardService keyboardService = HandleKeyboardService();
  final GlobalKey<FormState> globalKeyPharmacy = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final vm = initController(() => CreatePharmacyViewModel());

    if (widget.pharmacy != null) {
      final p = widget.pharmacy!;
      vm.nameController.text = p.name ?? "";
      vm.phoneController.text = p.phone ?? "";
      vm.selectedLatitude = p.latitude;
      vm.selectedLongitude = p.longitude;
      vm.walletController.text = p.asPharmacy?.walletNumber ?? "";
      vm.instapayNumberController.text = p.asPharmacy?.instapayNumber ?? "";
      vm.instapayLinkController.text = p.asPharmacy?.instapayLink ?? "";
      vm.isUpdate = true;
      vm.existingPharmacy = widget.pharmacy;
      vm.update();
    }

    if (widget.parentPharmacyId != null) {
      vm.parentPharmacyId = widget.parentPharmacyId;
      vm.update();
    }
  }

  @override
  Widget build(BuildContext context) {
    final keys = keyboardService.generateKeys('CreatePharmacyView', 5);

    return GetBuilder<CreatePharmacyViewModel>(
      init: CreatePharmacyViewModel(),
      builder: (controller) {
        return Container(
          height: 600.h,
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    controller.isUpdate
                        ? "تحديث بيانات الصيدلي"
                        : widget.parentPharmacyId != null
                            ? "إضافة موظف للصيدلية"
                            : "إضافة صيدلية جديدة",
                    style: context.typography.mdBold,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              // Form
              Expanded(
                child: KeyboardActions(
                  config: keyboardService.buildConfig(context, keys),
                  child: Form(
                    key: globalKeyPharmacy,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        CustomInputField(
                          label: "اسم الصيدلي",
                          controller: controller.nameController,
                          hintText: "ادخل اسم الصيدلي",
                          validator: InputValidators.combine([notEmptyValidator]),
                          focusNode: keyboardService.getFocusNode(keys[0]),
                          keyboardType: TextInputType.name,
                        ),
                        CustomInputField(
                          label: "الهاتف",
                          controller: controller.phoneController,
                          hintText: "ادخل الهاتف",
                          validator: InputValidators.combine([notEmptyValidator]),
                          focusNode: keyboardService.getFocusNode(keys[1]),
                          keyboardType: TextInputType.phone,
                        ),
                        SizedBox(height: 12.h),
                        _PharmacyLocationPickerWidget(controller: controller),
                        SizedBox(height: 16.h),

                        // بيانات الدفع — تظهر للصيدلية الأساسية فقط، لا للموظفين
                        if (widget.parentPharmacyId == null) ...[
                          _PaymentSectionHeader(),
                          SizedBox(height: 10.h),
                          CustomInputField(
                            label: "رقم المحفظة (اختياري)",
                            controller: controller.walletController,
                            hintText: "مثال: 01012345678",
                            focusNode: keyboardService.getFocusNode(keys[2]),
                            keyboardType: TextInputType.phone,
                            validator: (_) => null,
                          ),
                          CustomInputField(
                            label: "رقم InstaPay (اختياري)",
                            controller: controller.instapayNumberController,
                            hintText: "مثال: 01012345678",
                            focusNode: keyboardService.getFocusNode(keys[3]),
                            keyboardType: TextInputType.phone,
                            validator: (_) => null,
                          ),
                          CustomInputField(
                            label: "لينك InstaPay (اختياري)",
                            controller: controller.instapayLinkController,
                            hintText: "مثال: https://ipn.eg/...",
                            focusNode: keyboardService.getFocusNode(keys[4]),
                            keyboardType: TextInputType.url,
                            validator: (_) => null,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              Divider(height: 20.h),

              // ✅ Bottom Actions
              SafeArea(
                child: BottomNavigationActions(
                  rightTitle: controller.isUpdate
                      ? "تحديث الصيدلي"
                      : widget.parentPharmacyId != null
                          ? "إضافة الموظف"
                          : "إضافة الصيدلية",
                  rightAction: () {
                    if (globalKeyPharmacy.currentState?.validate() ?? false) {
                      controller.savePharmacy();
                    }
                  },
                  isRightEnabled: controller.validateStep(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PaymentSectionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.payment_outlined, color: AppColors.primary, size: 18),
          SizedBox(width: 8.w),
          AppText(
            text: "بيانات الدفع الإلكتروني",
            textStyle: context.typography.smSemiBold.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _PharmacyLocationPickerWidget extends StatelessWidget {
  final CreatePharmacyViewModel controller;
  const _PharmacyLocationPickerWidget({required this.controller});

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
