import 'package:lottie/lottie.dart';
import '../../../index/index_main.dart';

class NoDataAnimated extends StatelessWidget {
  final String title;
  final String? subtitle;

  /// Optional action button text
  final String? actionText;

  /// Optional action callback
  final VoidCallback? onAction;

  final String lottiePath;
  final double? height;

  const NoDataAnimated({
    super.key,
    this.title = "لا توجد بيانات",
    this.subtitle,
    this.actionText,
    this.onAction,
    this.lottiePath = "assets/lottie/empty-box.json",
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final double h = height ?? 220.h;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🔵 Animation
              SizedBox(
                height: h,
                child: Lottie.asset(
                  lottiePath,
                  repeat: true,
                  frameRate: FrameRate.max,
                ),
              ),

              SizedBox(height: 10.h),

              // 🔵 Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: context.typography.lgBold.copyWith(
                  color: AppColors.text_primary_paragraph,
                ),
              ),

              // 🔵 Subtitle (optional)
              if (subtitle != null) ...[
                SizedBox(height: 6.h),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: context.typography.smRegular.copyWith(
                    color: AppColors.textSecondaryParagraph,
                  ),
                ),
              ],

              // 🔵 Action Button (optional)
              if (actionText != null && onAction != null) ...[
                SizedBox(height: 18.h),
                SizedBox(
                  height: 46.h,
                  width: 180.w,
                  child: ElevatedButton(
                    onPressed: onAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      actionText!,
                      style: context.typography.mdBold.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
