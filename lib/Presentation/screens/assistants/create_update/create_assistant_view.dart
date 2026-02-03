import '../../../../../index/index_main.dart';

class CreateAssistantView extends StatefulWidget {
  final LocalUser? assistant; // ✅ assistant is stored in clients now

  const CreateAssistantView({Key? key, this.assistant}) : super(key: key);

  @override
  State<CreateAssistantView> createState() => _CreateAssistantViewState();
}

class _CreateAssistantViewState extends State<CreateAssistantView> {
  final HandleKeyboardService keyboardService = HandleKeyboardService();
  final GlobalKey<FormState> globalKeyAssistant = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final vm = initController(() => CreateAssistantViewModel());

    if (widget.assistant != null) {
      // Populate fields if editing

      vm.nameController.text = widget.assistant?.name ?? "";
      vm.phoneController.text = widget.assistant?.phone ?? "";
      vm.is_update = true;
      vm.existingAssistant = widget.assistant;
      vm.update();
    }
  }

  @override
  Widget build(BuildContext context) {
    final keys = keyboardService.generateKeys('CreateAssistantView', 3);

    return GetBuilder<CreateAssistantViewModel>(
      init: CreateAssistantViewModel(),
      builder: (controller) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                padding: EdgeInsets.symmetric( vertical: 10.h),
                child: KeyboardActions(
                  config: keyboardService.buildConfig(context, keys),
                  child: Form(
                    key: globalKeyAssistant,
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                controller.is_update
                                    ? "تحديث مساعد"
                                    : "إضافة مساعد جديد",
                                style: context.typography.mdBold,
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),

                          // 🔹 Assistant Name
                          CustomInputField(
                            label: "اسم المساعد",
                            controller: controller.nameController,
                            hintText: "ادخل اسم المساعد",
                            validator:
                            InputValidators.combine([notEmptyValidator]),
                            focusNode: keyboardService.getFocusNode(keys[0]),
                            keyboardType: TextInputType.name,
                          ),
                          SizedBox(height: 20.h),

                          // 🔹 Clinics Dropdown
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0),
                            child: DropdownButtonFormField<ClinicModel>(
                              value: controller.selectedClinic,
                              items: controller.list_clinics?.map((clinic) {
                                return DropdownMenuItem<ClinicModel>(
                                  value: clinic,
                                  child: Text(clinic?.title ?? "بدون اسم"),
                                );
                              }).toList(),
                              onChanged: (val) {
                                controller.selectedClinic = val;
                                controller.update();
                              },
                              decoration: InputDecoration(
                                labelText: "اختر العيادة",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (val) =>
                              val == null ? "يجب اختيار عيادة" : null,
                            ),
                          ),
                          SizedBox(height: 20.h),

                          // 🔹 Phone
                          CustomInputField(
                            label: "الهاتف",
                            controller: controller.phoneController,
                            hintText: "ادخل الهاتف",
                            validator:
                            InputValidators.combine([notEmptyValidator]),
                            focusNode: keyboardService.getFocusNode(keys[1]),
                            keyboardType: TextInputType.phone,
                          ),
                          SizedBox(height: 30.h),

                          // 🔹 Bottom Button
                          SafeArea(
                            child: BottomNavigationActions(
                              rightTitle: controller.is_update
                                  ? "تحديث المساعد"
                                  : "إضافة المساعد",
                              rightAction: () {
                                if (globalKeyAssistant.currentState
                                    ?.validate() ??
                                    false) {
                                  controller.saveAssistant();
                                }
                              },
                              isRightEnabled: controller.validateStep(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

}
