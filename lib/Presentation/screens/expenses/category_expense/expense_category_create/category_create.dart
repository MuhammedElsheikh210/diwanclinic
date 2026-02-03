// ✅ Updated CreateExpenseCategoryView to include "title" and a dropdown for "monthly" or "fixed"
import '../../../../../index/index_main.dart';
import 'category_creats_viewmodel.dart';

class CreateExpenseCategoryView extends StatefulWidget {
  final CategoryEntity? categoryEntity;

  const CreateExpenseCategoryView({Key? key, this.categoryEntity})
    : super(key: key);

  @override
  State<CreateExpenseCategoryView> createState() =>
      _CreateExpenseCategoryViewState();
}

class _CreateExpenseCategoryViewState extends State<CreateExpenseCategoryView> {
  final HandleKeyboardService keyboardService = HandleKeyboardService();
  final GlobalKey<FormState> globalKeyCategory = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final createCategoryVM = initController(() => CreateExpenseCategoryViewModel());
    if (widget.categoryEntity != null) {
      createCategoryVM.existingCategory = widget.categoryEntity;
      createCategoryVM.populateFields(widget.categoryEntity!);
      createCategoryVM.is_update = true;
    }

    createCategoryVM.update();
  }

  @override
  Widget build(BuildContext context) {
    final keys = keyboardService.generateKeys('CreateCategoryView', 2);

    return GetBuilder<CreateExpenseCategoryViewModel>(
      init: CreateExpenseCategoryViewModel(),
      builder: (controller) {
        return Container(
          height: 400.h,
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Column(
            children: [
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
              Expanded(
                child: KeyboardActions(
                  config: keyboardService.buildConfig(context, keys),
                  child: Form(
                    key: globalKeyCategory,
                    child: ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
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
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: GenericDropdown<GenericListModel>(
                            hint_text: "اختر النوع",
                            title: "نوع التصنيف",
                            items: controller.categoryTypeList,
                            initialValue: controller.selectedCategoryType,
                            onChanged: (value) {
                              controller.selectedCategoryType = value;
                              controller.update();
                            },
                            displayItemBuilder:
                                (item) => Text(
                                  item.name ?? "",
                                  style: context.typography.mdRegular.copyWith(
                                    color: ColorMappingImpl().textLabel,
                                  ),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
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
