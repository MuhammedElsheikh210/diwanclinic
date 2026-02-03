import '../../../../../index/index_main.dart';

class CreateCategoryView extends StatefulWidget {
  final CategoryEntity? categoryEntity;

  const CreateCategoryView({Key? key, this.categoryEntity}) : super(key: key);

  @override
  State<CreateCategoryView> createState() => _CreateCategoryViewState();
}

class _CreateCategoryViewState extends State<CreateCategoryView> {
  final HandleKeyboardService keyboardService = HandleKeyboardService();
  final GlobalKey<FormState> globalKeyCategory = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final createCategoryVM = initController(() => CreateCategoryViewModel());

    if (widget.categoryEntity != null) {
      createCategoryVM.existingCategory = widget.categoryEntity;
      createCategoryVM.populateFields(widget.categoryEntity!);
      createCategoryVM.is_update = true;
    }

    createCategoryVM.update();
  }

  @override
  Widget build(BuildContext context) {
    final keys = keyboardService.generateKeys('CreateCategoryView', 1);

    return GetBuilder<CreateCategoryViewModel>(
      init: CreateCategoryViewModel(),
      builder: (controller) {
        return Container(
          height: 300.h,
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Column(
            children: [
              // Header row (title + close button)
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

              // Form and scrollable content
              Expanded(
                child: KeyboardActions(
                  config: keyboardService.buildConfig(context, keys),
                  child: Form(
                    key: globalKeyCategory,
                    child: ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        // Category Name
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

              // Bottom Action Button(s)
              Divider(height: 20.h),
              SafeArea(
                child: BottomNavigationActions(
                  rightTitle: controller.is_update
                      ? "تحديث التصنيف"
                      : "إنشاء التصنيف",
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
