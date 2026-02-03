import '../../../../../../index/index_main.dart';

class ProductsButtons<T> extends StatelessWidget {
  final T? entity;
  final dynamic controller;
  final int index;
  final GenericButtonItem button;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductsButtons({
    super.key,
    required this.entity,
    required this.controller,
    required this.index,
    required this.button,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 15, bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
          InkWell(
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
                child: Icon(Icons.more_horiz, color: ColorMappingImpl().white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
