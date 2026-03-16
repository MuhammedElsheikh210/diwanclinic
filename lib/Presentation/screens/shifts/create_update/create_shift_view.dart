import '../../../../../index/index_main.dart';

class CreateShiftView extends StatefulWidget {
  final ShiftModel? shift;
  final String clinic_key;
  final String doctor_key;

  const CreateShiftView({
    Key? key,
    this.shift,
    required this.clinic_key,
    required this.doctor_key,
  }) : super(key: key);

  @override
  State<CreateShiftView> createState() => _CreateShiftViewState();
}

class _CreateShiftViewState extends State<CreateShiftView> {
  final HandleKeyboardService keyboardService = HandleKeyboardService();
  final GlobalKey<FormState> globalKeyShift = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final createShiftVM = initController(() => CreateShiftViewModel());
    createShiftVM.clinic_key = widget.clinic_key;
    createShiftVM.doctor_key = widget.doctor_key;

    if (widget.shift != null) {
      createShiftVM.existingShift = widget.shift;
      createShiftVM.populateFields(widget.shift!);
      createShiftVM.isUpdate = true;
    }

    createShiftVM.update();
  }

  @override
  Widget build(BuildContext context) {
    final keys = keyboardService.generateKeys('CreateShiftView', 3);

    return GetBuilder<CreateShiftViewModel>(
      init: CreateShiftViewModel(),
      builder: (controller) {
        return Container(
          height: 550.h,
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    controller.isUpdate ? "تحديث وردية" : "إضافة وردية جديدة",
                    style: context.typography.mdBold,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Expanded(
                child: KeyboardActions(
                  config: keyboardService.buildConfig(context, keys),
                  child: Form(
                    key: globalKeyShift,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        CustomInputField(
                          label: "اسم الوردية",
                          controller: controller.titleController,
                          hintText: "ادخل اسم الوردية",
                          validator: InputValidators.combine([
                            notEmptyValidator,
                          ]),
                          focusNode: keyboardService.getFocusNode(keys[0]),
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: 10.h),
                        CustomInputField(
                          label: "بداية الوردية",
                          controller: controller.startTimeController,
                          hintText: "ادخل وقت البداية",
                          validator: InputValidators.combine([
                            notEmptyValidator,
                          ]),
                          focusNode: keyboardService.getFocusNode(keys[1]),
                          keyboardType: TextInputType.datetime,
                        ),
                        SizedBox(height: 10.h),
                        CustomInputField(
                          label: "نهاية الوردية",
                          controller: controller.endTimeController,
                          hintText: "ادخل وقت النهاية",
                          validator: InputValidators.combine([
                            notEmptyValidator,
                          ]),
                          focusNode: keyboardService.getFocusNode(keys[2]),
                          keyboardType: TextInputType.datetime,
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ),
              Divider(height: 20.h),
              SafeArea(
                child: BottomNavigationActions(
                  rightTitle:
                      controller.isUpdate ? "تحديث الوردية" : "إضافة الوردية",
                  rightAction: controller.saveShift,
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
