import '../../../../index/index_main.dart';

class ButtonsListWidget extends StatelessWidget {
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  const ButtonsListWidget({
    Key? key,

    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: AppColors.white,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shrinkWrap: true,
          children: [
            _buildButton(
              context: context,
              label: "تعديل",
              icon: IconsConstants.updatedesc,
              onPressed: onUpdate,
            ),

            _buildButton(
              context: context,
              label: "حذف",
              icon: IconsConstants.cancel_deals,
              onPressed: () {
                Get.back();
                showDeleteBottomSheet(context, onDelete: onDelete);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String label,
    required String icon,
    required VoidCallback onPressed,
  }) {
    return ListTile(
      leading: Svgicon(icon: icon, width: 20, height: 20),
      title: Text(
        label,
        style: context.typography.smSemiBold.copyWith(
          color: ColorMappingImpl().textDefault,
        ),
      ),
      tileColor: ColorResources.COLOR_Primary,
      // Background color
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: onPressed,
    );
  }
}
