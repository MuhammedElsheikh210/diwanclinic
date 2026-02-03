import '../../../../index/index_main.dart';

class AppBarWithLogo extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWithLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      flexibleSpace: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Image.asset(
            Images.logo,
            fit: BoxFit.fill,
            width: 150.w, // Adjust path as needed
          ),
        ),
      ),
      actions: [
        InkWell(
          onTap: () {

          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Svgicon(icon: IconsConstants.notification_icon),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Divider(color: Colors.grey.shade300, height: 1, thickness: 0.5),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
