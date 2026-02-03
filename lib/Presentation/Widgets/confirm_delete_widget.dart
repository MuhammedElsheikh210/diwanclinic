import '../../../index/index_main.dart';

class ConfirmBottomSheet extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final Color confirmColor;
  final IconData icon;

  const ConfirmBottomSheet({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    required this.onConfirm,
    this.confirmColor = AppColors.errorForeground,
    this.icon = Icons.warning_amber_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 50.h, color: confirmColor),
            SizedBox(height: 10.h),
            AppText(
              text: title,
              textStyle: context.typography.lgBold.copyWith(
                color: AppColors.textDisplay,
                fontSize: 18.sp,
              ),
            ),
            SizedBox(height: 10.h),
            AppText(
              text: message,
              textStyle: context.typography.smMedium.copyWith(
                color: AppColors.textSecondaryParagraph,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),

            /// **Buttons Row**
            Row(
              children: [
                Expanded(
                  child: PrimaryTextButton(
                    label: AppText(
                      text: cancelText,
                      textStyle: context.typography.mdBold.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    onTap: () => Navigator.pop(context), // Close sheet
                    customBackgroundColor: AppColors.background_neutral_100,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: PrimaryTextButton(
                    label: AppText(
                      text: confirmText,
                      textStyle: context.typography.mdBold.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    onTap: () {
                      onConfirm();
                      Navigator.pop(context); // Close the sheet after action
                    },
                    customBackgroundColor: confirmColor,
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
