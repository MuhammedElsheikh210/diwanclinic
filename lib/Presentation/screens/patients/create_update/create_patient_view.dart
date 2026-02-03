import '../../../../../index/index_main.dart';

class CreatePatientView extends StatefulWidget {
  final PatientModel? patient;

  const CreatePatientView({Key? key, this.patient}) : super(key: key);

  @override
  State<CreatePatientView> createState() => _CreatePatientViewState();
}

class _CreatePatientViewState extends State<CreatePatientView> {
  final HandleKeyboardService keyboardService = HandleKeyboardService();
  final GlobalKey<FormState> globalKeyPatient = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final createPatientVM = initController(() => CreatePatientViewModel());

    if (widget.patient != null) {
      createPatientVM.existingPatient = widget.patient;
      createPatientVM.populateFields(widget.patient!);
      createPatientVM.is_update = true;
    }

    createPatientVM.update();
  }

  @override
  Widget build(BuildContext context) {
    final keys = keyboardService.generateKeys('CreatePatientView', 5);

    return GetBuilder<CreatePatientViewModel>(
      init: CreatePatientViewModel(),
      builder: (controller) {
        return Container(
          height: 650.h,
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    controller.is_update ? "تحديث مريض" : "إضافة مريض جديد",
                    style: context.typography.mdBold,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),

              Expanded(
                child: KeyboardActions(
                  config: keyboardService.buildConfig(context, keys),
                  child: Form(
                    key: globalKeyPatient,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        CustomInputField(
                          label: "اسم المريض",
                          controller: controller.nameController,
                          hintText: "ادخل اسم المريض",
                          validator: InputValidators.combine([
                            notEmptyValidator,
                          ]),
                          focusNode: keyboardService.getFocusNode(keys[0]),
                          keyboardType: TextInputType.name,
                        ),
                        SizedBox(height: 10.h),

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
                        SizedBox(height: 10.h),

                        CustomInputField(
                          label: "العنوان",
                          controller: controller.addressController,
                          hintText: "ادخل العنوان",
                          focusNode: keyboardService.getFocusNode(keys[2]),
                          validator: InputValidators.combine([
                            notEmptyValidator,
                          ]),

                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: 10.h),

                        CustomInputField(
                          label: "تاريخ الميلاد",
                          controller: controller.birthdayController,
                          hintText: "ادخل تاريخ الميلاد",
                          focusNode: keyboardService.getFocusNode(keys[3]),
                          keyboardType: TextInputType.datetime,
                          validator: InputValidators.combine([
                            notEmptyValidator,
                          ]),
                        ),
                        SizedBox(height: 10.h),


                      ],
                    ),
                  ),
                ),
              ),

              Divider(height: 20.h),
              SafeArea(
                child: BottomNavigationActions(
                  rightTitle: controller.is_update
                      ? "تحديث المريض"
                      : "إضافة المريض",
                  rightAction: controller.savePatient,
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
