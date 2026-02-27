import '../../../../../index/index_main.dart';

class CreateSalesView extends StatefulWidget {
  final LocalUser? sales; // ✅ Sales user passed if editing

  const CreateSalesView({Key? key, this.sales}) : super(key: key);

  @override
  State<CreateSalesView> createState() => _CreateSalesViewState();
}

class _CreateSalesViewState extends State<CreateSalesView> {
  final HandleKeyboardService keyboardService = HandleKeyboardService();
  final GlobalKey<FormState> globalKeySales = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final vm = initController(() => CreateSalesViewModel());

    if (widget.sales != null) {
      // Populate fields if editing
      vm.nameController.text = widget.sales?.name ?? "";
      vm.phoneController.text = widget.sales?.phone ?? "";
      vm.is_update = true;
      vm.existingSales = widget.sales;
      vm.update();
    }
  }

  @override
  Widget build(BuildContext context) {
    final keys = keyboardService.generateKeys('CreateSalesView', 2);

    return GetBuilder<CreateSalesViewModel>(
      init: CreateSalesViewModel(),
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
                        ? "تحديث مندوب المبيعات"
                        : "إضافة مندوب مبيعات جديد",
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
                    key: globalKeySales,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        CustomInputField(
                          label: "اسم المندوب",
                          controller: controller.nameController,
                          hintText: "ادخل اسم المندوب",
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
                      ? "تحديث المندوب"
                      : "إضافة المندوب",
                  rightAction: () {
                    if (globalKeySales.currentState?.validate() ?? false) {
                      controller.saveSales();
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
