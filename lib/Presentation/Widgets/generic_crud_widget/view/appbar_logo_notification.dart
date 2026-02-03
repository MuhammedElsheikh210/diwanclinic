import '../../../../index/index_main.dart';

class AppbarLogoWithNotificationIcon extends StatelessWidget {
  const AppbarLogoWithNotificationIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: ColorMappingImpl().white),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(Images.logo_brown),
                Expanded(child: Container()),
                const Svgicon(icon: IconsConstants.notification_icon),
              ],
            ),
          ),
          Divider(
            color: ColorMappingImpl().borderNeutralPrimary,
            height: 10,
            thickness: 0.5,
          ),
        ],
      ),
    );
  }
}
