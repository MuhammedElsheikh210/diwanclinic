import '../../../../../index/index_main.dart';

class CreateCategoryView extends StatefulWidget {
  final CategoryEntity? categoryEntity;

  /// ✅ Dynamic category type
  final String? categoryType;

  const CreateCategoryView({Key? key, this.categoryEntity, this.categoryType})
    : super(key: key);

  @override
  State<CreateCategoryView> createState() => _CreateCategoryViewState();
}

class _CreateCategoryViewState extends State<CreateCategoryView> {
  final HandleKeyboardService keyboardService = HandleKeyboardService();

  final GlobalKey<FormState> globalKeyCategory = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    final createCategoryVM = initController(
      () => CreateCategoryViewModel(categoryType: widget.categoryType),
    );

    if (widget.categoryEntity != null) {
      createCategoryVM.existingCategory = widget.categoryEntity;

      createCategoryVM.populateFields(widget.categoryEntity!);

      createCategoryVM.is_update = true;
    }

    createCategoryVM.update();
    print("saveCategory is ${widget.categoryEntity?.toJson()}");
    print("saveCategory is ${widget.categoryType}");
  }

  @override
  Widget build(BuildContext context) {
    final keys = keyboardService.generateKeys('CreateCategoryView', 1);

    return GetBuilder<CreateCategoryViewModel>(
      init: CreateCategoryViewModel(categoryType: widget.categoryType),

      builder: (controller) {
        return Container(
          height: 300.h,

          padding: EdgeInsets.symmetric(horizontal: 15.w),

          child: Column(
            children: [
              /// Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Text(
                    controller.is_update ? "تحديث التصنيف" : "إنشاء تصنيف جديد",

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

              /// Form
              Expanded(
                child: KeyboardActions(
                  config: keyboardService.buildConfig(context, keys),

                  child: Form(
                    key: globalKeyCategory,

                    child: ListView(
                      physics: const NeverScrollableScrollPhysics(),

                      shrinkWrap: true,

                      children: [
                        /// Category Name
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),

                          child: CustomInputField(
                            padding_horizontal: 0,

                            show_asterisc: false,

                            label: "اسم التصنيف",

                            voidCallbackAction: (value) {
                              controller.update();
                            },

                            hintText: "اسم التصنيف",

                            controller: controller.nameController,

                            keyboardType: TextInputType.name,

                            validator: InputValidators.combine([
                              notEmptyValidator,
                            ]),

                            focusNode: keyboardService.getFocusNode(keys[0]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// Bottom Actions
              Divider(height: 20.h),

              SafeArea(
                child: BottomNavigationActions(
                  rightTitle:
                      controller.is_update ? "تحديث التصنيف" : "إنشاء التصنيف",

                  rightAction: controller.saveCategory,

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
