import '../../../../index/index_main.dart';

class TitleAppBar extends StatelessWidget {
  final String title;
  final VoidCallback? onNotificationTap;
  final String notificationIcon;
  final bool showBackButton;
  final VoidCallback? onBackTap;

  const TitleAppBar({
    Key? key,
    required this.title,
    this.onNotificationTap,
    this.notificationIcon = IconsConstants.notification_icon,
    this.showBackButton = false,
    this.onBackTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: ColorMappingImpl().white),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button (Optional)
                if (showBackButton)
                  InkWell(
                    onTap: onBackTap ?? () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, size: 24),
                  )
                else
                  const SizedBox(width: 24), // Placeholder for alignment

                // Centered Title
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: context.typography.mdBold,
                  ),
                ),

                // Notification Icon (Clickable)
                InkWell(
                  onTap: onNotificationTap,
                  child: Svgicon(icon: notificationIcon),
                ),
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
