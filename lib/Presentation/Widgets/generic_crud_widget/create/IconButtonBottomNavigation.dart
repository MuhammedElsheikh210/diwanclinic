import '../../../../../index/index_main.dart';

class IconButtonBottomNavigation extends StatelessWidget {
  final Function()? callback;
  final String title;
  final String icon;
  final bool isleading;
  final Color color;

  const IconButtonBottomNavigation({
    super.key,
    required this.callback,
    required this.title,
    required this.color,
    required this.isleading,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: callback,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          isleading ? Svgicon(icon: icon) : Container(),
          const SizedBox(width: 10),
          AppText(
            text: title,
            textStyle: context.typography.mdBold.copyWith(
              color: color,
              fontSize: 20,
            ),
          ),
          const SizedBox(width: 10),
          !isleading ? Svgicon(icon: icon, color: color) : Container(),
        ],
      ),
    );
  }
}
