import '../../../../../index/index_main.dart';

class OrderButtonBar extends StatelessWidget {
  final String status;
  final VoidCallback? onPrimaryTap; // confirm
  final VoidCallback? onDetailsTap;
  final VoidCallback? onCancelTap;

  const OrderButtonBar({
    super.key,
    required this.status,
    this.onPrimaryTap,
    this.onDetailsTap,
    this.onCancelTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.typography;

    // --------------------------------
    // completed / cancelled / confirmed
    // → تفاصيل فقط
    // --------------------------------
    if (status == "completed" ||
        status == "cancelled" ||
        status == "confirmed") {
      return _detailsOnly(context, t);
    }

    // --------------------------------
    // pending / approved
    // → تفاصيل + إلغاء
    // --------------------------------
    if (status == "pending" || status == "approved") {
      return Row(
        children: [
          _detailsBtn(context, t),
          SizedBox(width: 10.w),
          _cancelBtn(context, t),
        ],
      );
    }

    // --------------------------------
    // calculated
    // → تفاصيل + إلغاء + تأكيد
    // --------------------------------
    if (status == "calculated") {
      return Row(
        children: [
          _detailsBtn(context, t),
          SizedBox(width: 10.w),
          _cancelBtn(context, t),
          SizedBox(width: 10.w),
          _confirmBtn(context, t),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  // --------------------------------------------------
  // Buttons
  // --------------------------------------------------

  Widget _detailsOnly(BuildContext context, AppTypography t) {
    return Row(children: [_detailsBtn(context, t)]);
  }

  Widget _detailsBtn(BuildContext context, AppTypography t) {
    return Expanded(
      child: PrimaryTextButton(
        onTap: onDetailsTap,
        appButtonSize: AppButtonSize.large,
        customBackgroundColor: AppColors.white,
        customBorder: const BorderSide(
          color: AppColors.borderNeutralPrimary,
          width: 1,
        ),
        label: AppText(
          text: "تفاصيل",
          textStyle: t.mdMedium.copyWith(color: AppColors.textDisplay),
        ),
      ),
    );
  }

  Widget _cancelBtn(BuildContext context, AppTypography t) {
    return Expanded(
      child: PrimaryTextButton(
        onTap: onCancelTap,
        appButtonSize: AppButtonSize.large,
        customBackgroundColor: AppColors.errorForeground,
        label: AppText(
          text: "إلغاء",
          textStyle: t.mdBold.copyWith(color: AppColors.white),
        ),
      ),
    );
  }

  Widget _confirmBtn(BuildContext context, AppTypography t) {
    return Expanded(
      child: PrimaryTextButton(
        onTap: onPrimaryTap,
        appButtonSize: AppButtonSize.large,
        customBackgroundColor: AppColors.primary,
        label: AppText(
          text: "تأكيد",
          textStyle: t.mdBold.copyWith(color: AppColors.white),
        ),
      ),
    );
  }
}
