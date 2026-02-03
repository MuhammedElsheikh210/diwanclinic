import '../../../../../index/index_main.dart';

class BottomNavigationNextPreviousActions extends StatelessWidget {
  final String leftTitle;
  final Function() leftAction;
  final bool isLeftEnabled;

  final String rightTitle;
  final Function() rightAction;
  final bool isRightEnabled;

  const BottomNavigationNextPreviousActions({
    super.key,
    required this.leftTitle,
    required this.leftAction,
    this.isLeftEnabled = true,
    required this.rightTitle,
    required this.rightAction,
    this.isRightEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 5),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Button (Previous)
            IconButtonBottomNavigation(
              callback: isLeftEnabled ? leftAction : () {},
              title: leftTitle,
              icon: IconsConstants.previous,
              isleading: true,
              color:
                  isLeftEnabled
                      ? AppColors.primary
                      : AppColors.textFieldBorderDefault,
            ),

            // Right Button (Next)
            IconButtonBottomNavigation(
              callback: isRightEnabled ? rightAction : () {},
              title: rightTitle,
              icon: IconsConstants.next,
              isleading: false,
              color:
                  isRightEnabled
                      ? AppColors.primary
                      : AppColors.textFieldBorderDefault,
            ),
          ],
        ),
      ),
    );
  }
}
