import '../../../../../index/index_main.dart';

class CreateAssistantView extends StatefulWidget {
  final LocalUser? assistant;

  const CreateAssistantView({Key? key, this.assistant}) : super(key: key);

  @override
  State<CreateAssistantView> createState() => _CreateAssistantViewState();
}

class _CreateAssistantViewState extends State<CreateAssistantView> {
  final HandleKeyboardService keyboardService = HandleKeyboardService();
  final GlobalKey<FormState> globalKeyAssistant = GlobalKey<FormState>();

  late final CreateAssistantViewModel vm;

  @override
  void initState() {
    super.initState();

    vm = initController(() => CreateAssistantViewModel());

    final assistant = widget.assistant;

    if (assistant != null && assistant.isAssistant) {
      final a = assistant.asAssistant;

      if (a == null) return;

      vm.nameController.text = a.name ?? "";
      vm.phoneController.text = a.phone ?? "";

      vm.isUpdate = true;
      vm.existingAssistant = assistant;

      vm.update();
    }
  }

  @override
  Widget build(BuildContext context) {
    final keys = keyboardService.generateKeys('CreateAssistantView', 3);

    return GetBuilder<CreateAssistantViewModel>(
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
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: KeyboardActions(
                  config: keyboardService.buildConfig(context, keys),
                  child: Form(
                    key: globalKeyAssistant,
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15.0,
                          vertical: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  controller.isUpdate
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

                            // 🔹 Name
                            CustomInputField(
                              label: "اسم المساعد",
                              controller: controller.nameController,
                              hintText: "ادخل اسم المساعد",
                              validator: InputValidators.combine([
                                notEmptyValidator,
                              ]),
                              focusNode: keyboardService.getFocusNode(keys[0]),
                              keyboardType: TextInputType.name,
                            ),

                            controller.medicalCenterKey != null
                                ? const SizedBox()
                                : SizedBox(height: 20.h),

                            // 🔹 Clinics
                            controller.medicalCenterKey != null
                                ? const SizedBox()
                                : Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0,
                                  ),
                                  child: DropdownButtonFormField<ClinicModel>(
                                    value: controller.selectedClinic,
                                    items:
                                        controller.listClinics?.map((clinic) {
                                          return DropdownMenuItem<ClinicModel>(
                                            value: clinic,
                                            child: Text(
                                              clinic?.title ?? "بدون اسم",
                                            ),
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
                                    validator:
                                        (val) =>
                                            val == null
                                                ? "يجب اختيار عيادة"
                                                : null,
                                  ),
                                ),

                            SizedBox(height: 20.h),

                            // 🔹 Phone
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

                            SizedBox(height: 30.h),

                            // 🔹 Button
                            SafeArea(
                              child: BottomNavigationActions(
                                rightTitle:
                                    controller.isUpdate
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
                ),
              );
            },
          ),
        );
      },
    );
  }
}
