import '../../../../../index/index_main.dart';

class PharmacyOrderButtonBar extends StatelessWidget {
  final String status;

  // Main actions
  final VoidCallback? onPricingTap;
  final VoidCallback? onApprovedTap;
  final VoidCallback? onDetailsTap;
  final VoidCallback? onCompleteTap;

  // Cancel (always available)
  final VoidCallback? onCancelTap;

  const PharmacyOrderButtonBar({
    super.key,
    required this.status,
    this.onPricingTap,
    this.onApprovedTap,
    this.onDetailsTap,
    this.onCancelTap,
    this.onCompleteTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.typography;

    // ------------------------------------------------
    // ❌ Cancelled → لا أزرار
    // ------------------------------------------------
    if (status == "cancelled") {
      return const SizedBox.shrink();
    }

    // الصيدلي يقدر يلغي في أي وقت (غير cancelled)
    final bool canCancel = status != "cancelled";

    Widget? mainButton;

    // ------------------------------------------------
    // Main action حسب الحالة
    // ------------------------------------------------
    switch (status) {
      case "pending":
        mainButton = PrimaryTextButton(
          onTap: onApprovedTap,
          appButtonSize: AppButtonSize.large,
          customBackgroundColor: AppColors.primary,
          label: AppText(
            text: "استلام",
            textStyle: t.mdBold.copyWith(color: AppColors.white),
          ),
        );
        break;

      case "approved":
        mainButton = PrimaryTextButton(
          onTap: onPricingTap,
          appButtonSize: AppButtonSize.large,
          customBackgroundColor: AppColors.tag_icon_warning,
          label: AppText(
            text: "بدء التسعير",
            textStyle: t.mdBold.copyWith(color: AppColors.white),
          ),
        );
        break;

      case "processing":
        mainButton = PrimaryTextButton(
          onTap: null,
          appButtonSize: AppButtonSize.large,
          customBackgroundColor: AppColors.grayLight,
          label: AppText(
            text: "جاري التسعير",
            textStyle: t.mdMedium.copyWith(
              color: AppColors.textSecondaryParagraph,
            ),
          ),
        );
        break;

      case "confirmed":
        mainButton = PrimaryTextButton(
          onTap: onCompleteTap,
          appButtonSize: AppButtonSize.large,
          customBackgroundColor: AppColors.primary,
          label: AppText(
            text: "توصيل الأوردر",
            textStyle: t.mdBold.copyWith(color: AppColors.white),
          ),
        );
        break;

      default:
        mainButton = null;
    }

    // ------------------------------------------------
    // UI النهائي
    // ------------------------------------------------
    return Row(
      children: [
        // ❌ Cancel (دايمًا موجود)
        if (canCancel)
          Expanded(
            child: PrimaryTextButton(
              onTap: onCancelTap,
              appButtonSize: AppButtonSize.large,
              customBackgroundColor: AppColors.errorForeground,
              label: AppText(
                text: "إلغاء",
                textStyle: t.mdBold.copyWith(color: AppColors.white),
              ),
            ),
          ),

        if (canCancel && mainButton != null) const SizedBox(width: 12),

        // ✅ Main action
        if (mainButton != null) Expanded(child: mainButton),
      ],
    );
  }
}
