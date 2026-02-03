// -------------------------------
// PharmacyOrderButtonBar
// -------------------------------
import '../../../../../index/index_main.dart';

class PharmacyOrderButtonBar extends StatelessWidget {
  final String status;
  final VoidCallback? onPricingTap;
  final VoidCallback? onApprovedTap;
  final VoidCallback? onDetailsTap;

  const PharmacyOrderButtonBar({
    super.key,
    required this.status,
    this.onPricingTap,
    this.onApprovedTap,
    this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.typography;

    // --------------------------------
    // cancelled → لا أزرار
    // --------------------------------
    if (status == "cancelled") {
      return const SizedBox.shrink();
    }

    // --------------------------------
    // pending → زر استلام
    // --------------------------------
    if (status == "pending") {
      return _singleButton(
        label: "استلام",
        color: AppColors.primary,
        textStyle: t.mdBold.copyWith(color: AppColors.white),
        onTap: onApprovedTap, // 👉 approved
      );
    }

    // --------------------------------
    // approved → زر جاري التسعير
    // --------------------------------
    if (status == "approved") {
      return _singleButton(
        label: "جاري التسعير",
        color: AppColors.tag_icon_warning,
        textStyle: t.mdBold.copyWith(color: AppColors.white),
        onTap: onPricingTap, // 👉 processing
      );
    }

    // --------------------------------
    // processing → جاري التسعير (Disabled)
    // --------------------------------
    if (status == "processing") {
      return _singleButton(
        label: "جاري التسعير",
        color: AppColors.grayLight,
        textStyle: t.mdMedium.copyWith(color: AppColors.textSecondaryParagraph),
        onTap: null,
      );
    }

    return const SizedBox.shrink();
  }

  // --------------------------------------------------
  // 🔧 Helper: Single Button
  // --------------------------------------------------
  Widget _singleButton({
    required String label,
    required Color color,
    required TextStyle textStyle,
    VoidCallback? onTap,
  }) {
    return Row(
      children: [
        Expanded(
          child: PrimaryTextButton(
            onTap: onTap,
            appButtonSize: AppButtonSize.large,
            customBackgroundColor: color,
            label: AppText(text: label, textStyle: textStyle),
          ),
        ),
      ],
    );
  }
}
