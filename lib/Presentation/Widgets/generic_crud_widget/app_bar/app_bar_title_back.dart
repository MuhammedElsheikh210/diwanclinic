
import '../../../../index/index_main.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final Color backgroundColor;
  final bool showBottomDivider;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.leading,
    this.actions,
    this.backgroundColor = Colors.white,
    this.showBottomDivider = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: context.typography.xlBold.copyWith(
          color: AppColors.background_black,
        ),
      ),
      backgroundColor: backgroundColor,

      leading: leading,
      actions: actions,
      bottom:
          showBottomDivider
              ? PreferredSize(
                preferredSize: const Size.fromHeight(1.0),
                child: Divider(
                  color: Colors.grey.shade300,
                  height: 1,
                  thickness: 0.5,
                ),
              )
              : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
