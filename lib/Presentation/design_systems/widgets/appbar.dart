import '../../../../index/index_main.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onFilterTap;
  final bool? showNotificationDot;
  final bool showFilterIcon; // ✅ Flag to toggle filter visibility

  const HomeAppBar({
    super.key,
    required this.title,
    this.onNotificationTap,
    this.onFilterTap,
    this.showNotificationDot,
    this.showFilterIcon = true, // ✅ default true
  });

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;

    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 72.h,
      centerTitle: false,
      titleSpacing: 0,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// 🔹 Title
            AppText(
              text: title,
              textStyle: typography.lgBold.copyWith(
                color: AppColors.background_black,
                fontWeight: FontWeight.w700,
              ),
            ),

            /// 🔹 Right Actions (Notification + Filter)
            Row(
              children: [
                // 🔔 Notification Icon
                showNotificationDot != null
                    ? const SizedBox()
                    : InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: onNotificationTap,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            SvgPicture.asset(
                              IconsConstants.arrival,
                              height: 32.h,
                              width: 32.w,
                            ),
                          ],
                        ),
                      ),

                /// Filter Icon (Conditional)
                if (showFilterIcon) ...[
                  const SizedBox(width: 15),
                  InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: onFilterTap,
                    child: SvgPicture.asset(
                      IconsConstants.filter,
                      height: 27.h,
                      width: 27.w,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),

      /// 🔹 Bottom Border
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1.2,
          color: AppColors.borderNeutralPrimary.withValues(alpha: 0.25),
        ),
      ),
      shadowColor: AppColors.grayMedium,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(72.h);
}
