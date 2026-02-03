import '../../../../../index/index_main.dart';

class BottomNavigationActions extends StatelessWidget {
  final String rightTitle;
  final Function() rightAction;
  final bool isRightEnabled;

  const BottomNavigationActions({
    super.key,
    required this.rightTitle,
    required this.rightAction,
    this.isRightEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 5),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Right Button (Generic)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButtonBottomNavigation(
                callback: isRightEnabled ? rightAction : () {},
                title: rightTitle,
                icon: IconsConstants.next,
                isleading: false,
                color: isRightEnabled
                    ? AppColors.primary
                    : AppColors.textFieldBorderDefault,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
