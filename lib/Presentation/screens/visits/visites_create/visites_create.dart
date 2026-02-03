import 'package:intl/intl.dart';
import 'package:diwanclinic/Presentation/screens/visits/visites_create/visites_creats_viewmodel.dart';
import '../../../../../index/index_main.dart';

class CreateVisitView extends StatefulWidget {
  final VisitModel? visitModel;

  const CreateVisitView({Key? key, this.visitModel}) : super(key: key);

  @override
  State<CreateVisitView> createState() => _CreateVisitViewState();
}

class _CreateVisitViewState extends State<CreateVisitView> {
  final HandleKeyboardService keyboardService = HandleKeyboardService();
  final GlobalKey<FormState> globalKeyVisit = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final createVisitVM = initController(() => CreateVisitViewModel());

    if (widget.visitModel != null) {
      createVisitVM.existingVisit = widget.visitModel;
      createVisitVM.populateFields(widget.visitModel!);
      createVisitVM.is_update = true;
    }

    createVisitVM.update();
  }

  @override
  Widget build(BuildContext context) {
    final keys = keyboardService.generateKeys('CreateVisitView', 5);

    return GetBuilder<CreateVisitViewModel>(
      init: CreateVisitViewModel(),
      builder: (controller) {
        return Container(
          height: 650.h,
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Column(
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    controller.is_update
                        ? "تحديث الزيارة"
                        : "إنشاء زيارة جديدة",
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
                    key: globalKeyVisit,
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        CustomInputField(
                          padding_horizontal: 0,
                          show_asterisc: false,
                          label: "اسم الدكتور",
                          hintText: "اسم الدكتور",
                          controller: controller.nameController,
                          keyboardType: TextInputType.name,
                          validator: InputValidators.combine([
                            notEmptyValidator,
                          ]),
                          focusNode: keyboardService.getFocusNode(keys[0]),
                        ),
                        SizedBox(height: 12.h),
                        CustomInputField(
                          padding_horizontal: 0,
                          show_asterisc: false,
                          label: "العنوان",
                          hintText: "عنوان الزيارة",
                          controller: controller.addressController,
                          keyboardType: TextInputType.streetAddress,
                          validator: InputValidators.combine([
                            notEmptyValidator,
                          ]),
                          focusNode: keyboardService.getFocusNode(keys[1]),
                        ),
                        SizedBox(height: 12.h),
                        CustomInputField(
                          padding_horizontal: 0,
                          show_asterisc: false,
                          label: "رقم الهاتف",
                          hintText: "رقم الهاتف",
                          controller: controller.phoneController,
                          keyboardType: TextInputType.phone,
                          validator: InputValidators.combine([
                            notEmptyValidator,
                          ]),
                          focusNode: keyboardService.getFocusNode(keys[2]),
                        ),
                        SizedBox(height: 12.h),
                        CustomInputField(
                          padding_horizontal: 0,
                          show_asterisc: false,
                          label: "ملاحظات",
                          hintText: "أضف ملاحظة إن وجدت",
                          controller: controller.commentController,
                          keyboardType: TextInputType.text,
                          focusNode: keyboardService.getFocusNode(keys[3]), validator: (String? p1) {  },
                        ),
                        SizedBox(height: 20.h),

                        /// 🔹 Date Picker Section
                        Text(
                          "تاريخ الزيارة",
                          style: context.typography.mdMedium.copyWith(
                            color: ColorResources.COLOR_BLACK,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        CalenderWidget(
                          hintText: "اختر تاريخ الزيارة",
                          initialTimestamp: controller.selectedDate ??
                              DateTime.now().millisecondsSinceEpoch,
                          onDateSelected: (timestamp, formattedDate) {
                            final date = timestamp.toDate();
                            final formatted =
                            DateFormat('dd/MM/yyyy').format(date);

                            controller.visitDate = formatted;
                            controller.selectedDate =
                                date.millisecondsSinceEpoch;

                            controller.update();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Divider(height: 20.h),

              // Save Button
              SafeArea(
                child: BottomNavigationActions(
                  rightTitle: controller.is_update
                      ? "تحديث الزيارة"
                      : "إنشاء الزيارة",
                  rightAction: controller.saveVisit,
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
