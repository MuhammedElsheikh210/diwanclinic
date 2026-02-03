import '../../../../index/index_main.dart';

class LogoutDialog extends StatefulWidget {
  const LogoutDialog({super.key});

  @override
  _LogoutDialogState createState() => _LogoutDialogState();
}

class _LogoutDialogState extends State<LogoutDialog> {
  final colors = ColorMappingImpl();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      backgroundColor: colors.backgroundDefault,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // **Icon**
            Icon(
              FontAwesomeIcons.handshakeSimple,
              size: 48.w,
              color: colors.primaryButtonDefault,
            ),
            SizedBox(height: 16.h),

            // **Title**
            AppText(
              text: 'نراك قريبًا'.tr,
              textStyle: context.typography.lgBold.copyWith(
                color: colors.textDisplay,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),

            // **Subtitle**
            AppText(
              text: 'هل أنت متأكد أنك تريد تسجيل الخروج؟'.tr,
              textStyle: context.typography.mdRegular.copyWith(
                color: colors.textSecondaryParagraph,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),

            // **Buttons**
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: PrimaryTextButton(
                    customBorder: BorderSide(
                      color: colors.borderNeutralPrimary,
                      width: 1,
                    ),
                    customBackgroundColor: colors.backgroundDefault,
                    elevation: 0,
                    onTap: () => Navigator.of(context).pop(),
                    label: AppText(
                      text: "إلغاء".tr,
                      textStyle: context.typography.mdMedium.copyWith(
                        color: colors.focusedTextColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: PrimaryTextButton(
                    appButtonSize: AppButtonSize.large,
                    onTap: () async {
                      // Logout logic
                      await LocalUser().getUserData().removeLocalUser();
                      Get.offAllNamed(loginView);
                    },
                    label: AppText(
                      text: " تسجيل الخروج".tr,
                      textStyle: context.typography.mdMedium,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
