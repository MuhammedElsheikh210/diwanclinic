import '../../../../index/index_main.dart';

class HomePatientAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomePatientAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(70.h);

  @override
  Widget build(BuildContext context) {
    final currentUser = Get.find<UserSession>().user;

    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      centerTitle: false,

      title: Row(
        children: [
          SizedBox(width: 10.w),
          _buildProfileAvatar(),

          SizedBox(width: 12.w),

          // --- Text Area
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "أهلاً بك",
                style: context.typography.smRegular.copyWith(
                  color: AppColors.textSecondaryParagraph,
                ),
              ),

              Text(
                currentUser?.user.name ?? "",

                style: context.typography.mdBold.copyWith(
                  color: AppColors.background_black,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
        ],
      ),

      actions: [
        _circleActionButton(
          onTap: () => Get.toNamed(notificationsView),
          icon: IconsConstants.notification,
        ),
        SizedBox(width: 5.w),

        _circleActionButton(
          onTap: () => Get.toNamed(accountView),
          icon: IconsConstants.account,
        ),
        SizedBox(width: 14.w),
      ],
    );
  }

  // ------------------------------------------------------------
  // 🟢 Profile Avatar
  // ------------------------------------------------------------
  Widget _buildProfileAvatar() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.background_black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(60),
        child: Image.asset(
          Images.logo_brown,
          width: 50.w,
          height: 50.w,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // 🟣 Action Button (Notification - Account)
  // ------------------------------------------------------------
  Widget _circleActionButton({
    required VoidCallback onTap,
    required String icon,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.w,
        margin: EdgeInsets.only(right: 4.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white,
          border: Border.all(color: AppColors.borderNeutralPrimary, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.background_black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(child: SvgPicture.asset(icon, width: 20.w, height: 20.h)),
      ),
    );
  }
}
