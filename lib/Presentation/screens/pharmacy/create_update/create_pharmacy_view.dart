import '../../../../../index/index_main.dart';

class CreatePharmacyView extends StatefulWidget {
  final LocalUser? pharmacy; // ✅ Pharmacy user passed if editing

  const CreatePharmacyView({Key? key, this.pharmacy}) : super(key: key);

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
      vm.nameController.text = widget.pharmacy?.name ?? "";
      vm.phoneController.text = widget.pharmacy?.phone ?? "";
      vm.is_update = true;
      vm.existingPharmacy = widget.pharmacy;
      vm.update();
    }
  }

  @override
  Widget build(BuildContext context) {
    final keys = keyboardService.generateKeys('CreatePharmacyView', 2);

    return GetBuilder<CreatePharmacyViewModel>(
      init: CreatePharmacyViewModel(),
      builder: (controller) {
        return Container(
          height: 400.h,
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    controller.is_update
                        ? "تحديث الصيدلي"
                        : "إضافة صيدلي جديد",
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
                          validator: InputValidators.combine([
                            notEmptyValidator,
                          ]),
                          focusNode: keyboardService.getFocusNode(keys[0]),
                          keyboardType: TextInputType.name,
                        ),
                        CustomInputField(
                          label: "الهاتف",
                          controller: controller.phoneController,
                          hintText: "ادخل الهاتف",
                          validator: InputValidators.combine([
                            notEmptyValidator,
                          ]),
                          focusNode: keyboardService.getFocusNode(keys[1]),
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Divider(height: 20.h),

              // ✅ Bottom Actions
              SafeArea(
                child: BottomNavigationActions(
                  rightTitle: controller.is_update
                      ? "تحديث الصيدلي"
                      : "إضافة الصيدلي",
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
