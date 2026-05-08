import '../../../../../index/index_main.dart';

class MedicalPropertyCreate extends StatefulWidget {
  final CategoryEntity? categoryEntity;

  /// ✅ Dynamic category type
  final String? categoryType;

  /// ✅ Existing property for update
  final MedicalRecordPropertyModel? property;

  const MedicalPropertyCreate({
    Key? key,
    this.categoryEntity,
    this.categoryType,
    this.property,
  }) : super(key: key);

  @override
  State<MedicalPropertyCreate> createState() =>
      _MedicalPropertyCreateState();
}

class _MedicalPropertyCreateState
    extends State<MedicalPropertyCreate> {
  final HandleKeyboardService keyboardService =
  HandleKeyboardService();

  final GlobalKey<FormState> globalKeyCategory =
  GlobalKey<FormState>();

  /// ✅ LOCAL INSTANCE ONLY
  late final MedicalPropertyCreatsViewmodel controller;

  @override
  void initState() {
    super.initState();

    /// ✅ DON'T USE GET.PUT HERE
    controller =
        MedicalPropertyCreatsViewmodel(
          categoryType:
          widget.categoryType,

          categoryEntity:
          widget.categoryEntity,
        );

    /// ✅ Update Mode
    if (widget.property != null) {
      controller.populateFields(
        widget.property!,
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keys =
    keyboardService.generateKeys(
      'MedicalPropertyCreate',
      2,
    );

    return GetBuilder<
        MedicalPropertyCreatsViewmodel>(
      /// ✅ PURE LOCAL CONTROLLER
      init: controller,

      global: false,

      builder: (controller) {
        return Container(
          height: 420.h,

          padding:
          EdgeInsets.symmetric(
            horizontal: 15.w,
          ),

          child: Column(
            children: [
              /// Header
              Row(
                mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,

                children: [
                  Text(
                    controller.is_update
                        ? "تحديث الخاصية"
                        : "إنشاء خاصية جديدة",

                    style: context
                        .typography
                        .mdBold,
                  ),

                  IconButton(
                    icon: const Icon(
                      Icons.close,
                    ),

                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pop();
                    },
                  ),
                ],
              ),

              /// Form
              Expanded(
                child: KeyboardActions(
                  config: keyboardService
                      .buildConfig(
                    context,
                    keys,
                  ),

                  child: Form(
                    key:
                    globalKeyCategory,

                    child: ListView(
                      physics:
                      const BouncingScrollPhysics(),

                      shrinkWrap:
                      true,

                      children: [
                        /// Property Name
                        Padding(
                          padding:
                          EdgeInsets.symmetric(
                            vertical:
                            10.h,
                          ),

                          child:
                          CustomInputField(
                            padding_horizontal:
                            0,

                            show_asterisc:
                            false,

                            label:
                            "اسم الخاصية",

                            hintText:
                            "مثال : وزن الجنين",

                            controller:
                            controller
                                .nameController,

                            keyboardType:
                            TextInputType
                                .name,

                            validator:
                            InputValidators.combine([
                              notEmptyValidator,
                            ]),

                            voidCallbackAction:
                                (
                                value,
                                ) {
                              controller
                                  .update();
                            },

                            focusNode:
                            keyboardService
                                .getFocusNode(
                              keys[0],
                            ),
                          ),
                        ),

                        /// Property Type
                        Padding(
                          padding:
                          EdgeInsets.only(
                            top: 10.h,
                            bottom:
                            10.h,
                          ),

                          child:
                          GenericDropdown<
                              GenericListModel>(
                            hint_text:
                            "اختر نوع القيمة",

                            title:
                            "نوع القيمة",

                            items: [
                              GenericListModel(
                                key:
                                "text",

                                name:
                                "نص",
                              ),

                              GenericListModel(
                                key:
                                "number",

                                name:
                                "رقم",
                              ),

                              GenericListModel(
                                key:
                                "date",

                                name:
                                "تاريخ",
                              ),
                            ],

                            initialValue:
                            controller.selectedType ==
                                null
                                ? null
                                : GenericListModel(
                              key:
                              controller.selectedType,

                              name:
                              controller.selectedType ==
                                  "number"
                                  ? "رقم"
                                  : controller.selectedType ==
                                  "date"
                                  ? "تاريخ"
                                  : "نص",
                            ),

                            onChanged:
                                (val) {
                              controller.selectedType =
                                  val.key;

                              controller
                                  .update();
                            },

                            displayItemBuilder:
                                (item) =>
                                Text(
                                  item.name ??
                                      "",

                                  style: context
                                      .typography
                                      .mdRegular
                                      .copyWith(
                                    color:
                                    ColorMappingImpl()
                                        .textLabel,
                                  ),
                                ),
                          ),
                        ),

                        /// Info
                        Padding(
                          padding:
                          EdgeInsets.only(
                            top: 5.h,
                          ),

                          child: Text(
                            "سيظهر هذا الحقل داخل الكشف للطبيب أثناء إدخال البيانات",

                            style: context
                                .typography
                                .smRegular
                                .copyWith(
                              color:
                              AppColors.grayLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// Bottom Actions
              Divider(
                height: 20.h,
              ),

              SafeArea(
                child:
                BottomNavigationActions(
                  rightTitle:
                  controller
                      .is_update
                      ? "تحديث الخاصية"
                      : "إنشاء الخاصية",

                  rightAction:
                  controller
                      .saveProperty,

                  isRightEnabled:
                  controller
                      .validateStep(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}