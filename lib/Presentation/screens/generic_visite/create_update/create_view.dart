import 'package:diwanclinic/Presentation/screens/generic_visite/create_update/create_visit_view_model.dart';

import '../../../../../index/index_main.dart';

class CreateVisitGenericView extends StatefulWidget {
  final VisitModel? visit;

  const CreateVisitGenericView({Key? key, this.visit}) : super(key: key);

  @override
  State<CreateVisitGenericView> createState() => _CreateVisitGenericViewState();
}

class _CreateVisitGenericViewState extends State<CreateVisitGenericView> {
  final HandleKeyboardService keyboardService = HandleKeyboardService();

  final GlobalKey<FormState> globalKeyVisit = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    final vm = initController(() => CreateVisitModel());

    if (widget.visit != null) {
      vm.existingVisit = widget.visit;

      vm.populateFields(widget.visit!);

      vm.isUpdate = true;
    }

    vm.update();
  }

  @override
  Widget build(BuildContext context) {
    final keys = keyboardService.generateKeys('CreateVisitView', 3);

    return GetBuilder<CreateVisitModel>(
      init: CreateVisitModel(),

      builder: (controller) {
        return Container(
          height: 450.h,

          padding: EdgeInsets.symmetric(horizontal: 15.w),

          child: Column(
            children: [
              /// =========================
              /// HEADER
              /// =========================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Text(
                    controller.isUpdate ? "تحديث الزيارة" : "إنشاء زيارة جديدة",

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

              /// =========================
              /// FORM
              /// =========================
              Expanded(
                child: KeyboardActions(
                  config: keyboardService.buildConfig(context, keys),

                  child: Form(
                    key: globalKeyVisit,

                    child: ListView(
                      physics: const NeverScrollableScrollPhysics(),

                      shrinkWrap: true,

                      children: [
                        /// =========================
                        /// NAME
                        /// =========================
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),

                          child: CustomInputField(
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

                            voidCallbackAction: (value) {
                              controller.update();
                            },
                          ),
                        ),

                        /// =========================
                        /// PHONE
                        /// =========================
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),

                          child: CustomInputField(
                            padding_horizontal: 0,

                            show_asterisc: false,

                            label: "رقم الهاتف",

                            hintText: "رقم الهاتف",

                            controller: controller.phoneController,

                            keyboardType: TextInputType.phone,

                            focusNode: keyboardService.getFocusNode(keys[1]),

                            voidCallbackAction: (value) {
                              controller.update();
                            },
                            validator: (String? p1) {},
                          ),
                        ),

                        /// =========================
                        /// ADDRESS
                        /// =========================
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),

                          child: CustomInputField(
                            padding_horizontal: 0,

                            show_asterisc: false,

                            label: "العنوان",

                            hintText: "العنوان",

                            controller: controller.addressController,

                            keyboardType: TextInputType.text,

                            focusNode: keyboardService.getFocusNode(keys[2]),

                            voidCallbackAction: (value) {
                              controller.update();
                            },
                            validator: (String? p1) {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// =========================
              /// ACTIONS
              /// =========================
              Divider(height: 20.h),

              SafeArea(
                child: BottomNavigationActions(
                  rightTitle:
                      controller.isUpdate ? "تحديث الزيارة" : "إنشاء الزيارة",

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
