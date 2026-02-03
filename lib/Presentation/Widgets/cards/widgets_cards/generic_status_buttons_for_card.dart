import '../../../../../../index/index_main.dart';

class GenericThreeButtonWidget<T> extends StatelessWidget {
  final T? entity;
  final dynamic controller;
  final int index;
  final bool? show_details;
  final bool? show_edit_delete;
  final List<GenericButtonItem> buttons;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const GenericThreeButtonWidget({
    super.key,
    required this.entity,
    required this.controller,
    required this.index,
    this.show_details,
    this.show_edit_delete,
    required this.buttons,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 15, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Visibility(
            visible: show_details == true,
            child: PrimaryTextButton(
              onTap: () {},
              appButtonSize: AppButtonSize.large,
              customBackgroundColor: ColorMappingImpl().white,
              elevation: 0,
              customBorder: BorderSide(
                color: ColorMappingImpl().borderNeutralPrimary,
                width: 1,
              ),
              label: AppText(
                text: "تفاصيل الفاتورة",
                textStyle: context.typography.mdMedium.copyWith(
                  color: ColorMappingImpl().textDefault,
                ),
              ),
            ),
          ),
          for (var button in buttons)
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: PrimaryTextButton(
                  onTap: button.onTap,
                  appButtonSize: AppButtonSize.large,
                  customBackgroundColor: ColorMappingImpl().white,
                  elevation: 0,
                  customBorder: BorderSide(
                    color: ColorMappingImpl().borderNeutralPrimary,
                    width: 1,
                  ),
                  label: AppText(
                    text: button.label,
                    textStyle: context.typography.mdMedium.copyWith(
                      color: ColorMappingImpl().textDefault,
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(width: 5),
          show_edit_delete == true
              ? const SizedBox()
              : InkWell(
                onTap: () {
                  showCustomBottomSheet(
                    context: context,
                    child: ButtonsListWidget(
                      onUpdate: () {
                        Get.back();
                        onEdit();
                      },
                      onDelete: () {
                        Get.back();
                        onDelete();
                      },
                    ),
                  );
                },

                child: SizedBox(
                  width: 45,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: ColorMappingImpl().primaryButtonEnabled,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Icon(
                      Icons.more_horiz,
                      color: ColorMappingImpl().white,
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class GenericButtonItem {
  final String label;
  final VoidCallback onTap;

  GenericButtonItem({required this.label, required this.onTap});
}
