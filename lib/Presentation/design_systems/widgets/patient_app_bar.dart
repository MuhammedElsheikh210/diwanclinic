import '../../../../index/index_main.dart';

class PatientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onFilterTap;
  final VoidCallback? onAccountTap;
  final bool showNotificationDot;
  final bool showFilterIcon; // ✅ toggle filter visibility

  const PatientAppBar({
    super.key,
    required this.title,
    this.onNotificationTap,
    this.onFilterTap,
    this.onAccountTap,
    this.showNotificationDot = false,
    this.showFilterIcon = true,
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
                fontSize: 20.sp,
              ),
            ),

            /// 🔹 Right Actions (Notification + Filter + Account)
            Row(
              children: [
                // 🔔 Notification Icon
                InkWell(
                  borderRadius: BorderRadius.circular(50.r),
                  onTap: onNotificationTap,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SvgPicture.asset(
                        IconsConstants.notification,
                        height: 30.h,
                        width: 30.w,
                      ),
                      if (showNotificationDot)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            height: 9.w,
                            width: 9.w,
                            decoration: BoxDecoration(
                              color: AppColors.errorForeground,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.white,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                /// Filter Icon (optional)
                if (showFilterIcon) ...[
                  SizedBox(width: 15.w),
                  InkWell(
                    borderRadius: BorderRadius.circular(50.r),
                    onTap: onFilterTap,
                    child: SvgPicture.asset(
                      IconsConstants.filter,
                      height: 28.h,
                      width: 28.w,
                    ),
                  ),
                ],

                /// 👤 Account Icon
                SizedBox(width: 15.w),
                InkWell(
                  borderRadius: BorderRadius.circular(50.r),
                  onTap: onAccountTap,
                  child: CircleAvatar(
                    radius: 17.r,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: AppColors.primary,
                      size: 22.sp,
                    ),
                  ),
                ),
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
