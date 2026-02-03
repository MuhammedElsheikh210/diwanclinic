import '../../../../../index/index.dart';

class StatusColors {
  final Color badgeColor;
  final Color textColor;

  StatusColors({required this.badgeColor, required this.textColor});
}

String getInvoiceStatus(String total, String rest) {
  double totalAmount = double.tryParse(total) ?? 0.0;
  double restAmount = double.tryParse(rest) ?? 0.0;

  if (restAmount == 0) {
    return "منتهية";
  } else if (restAmount > 0 && restAmount < totalAmount) {
    return "جاري";
  } else if (restAmount == totalAmount) {
    return "";
  }
  return "Unknown";
}

/// Function to get the corresponding status color
Color getStatusColor(String total, String rest) {
  double totalAmount = double.tryParse(total) ?? 0.0;
  double restAmount = double.tryParse(rest) ?? 0.0;

  if (restAmount == 0) {
    return AppColors.primary;
  } else if (restAmount > 0 && restAmount < totalAmount) {
    return AppColors.primary80;
  } else if (restAmount == totalAmount) {
    return AppColors.primary80;
  }
  return Colors.grey; // Default fallback color
}

StatusColors getStatusColors(String status) {
  switch (status.toLowerCase()) {
    case "comming":
      return StatusColors(
        badgeColor: ColorMappingImpl().background_warning_light,
        textColor: ColorMappingImpl().tag_icon_warning,
      );
    case "current":
      return StatusColors(
        badgeColor: AppColors.pending.withValues(alpha: 0.5),
        textColor: AppColors.pending,
      );
    case "submitted":
      return StatusColors(
        badgeColor: AppColors.primary_light,
        textColor: ColorMappingImpl().primaryTextButton,
      );
    case "finished":
      return StatusColors(
        badgeColor: AppColors.primary_light,
        textColor: ColorMappingImpl().primaryButtonEnabled,
      );
    case "rejected":
      return StatusColors(
        badgeColor: ColorMappingImpl().background_error_light,
        textColor: ColorMappingImpl().tag_text_error,
      );
    case "cancel":
      return StatusColors(
        badgeColor: ColorMappingImpl().background_error_light,
        textColor: ColorMappingImpl().tag_text_error,
      );
    case "closed":
      return StatusColors(
        badgeColor: AppColors.closed_background.withValues(alpha: 0.5),
        textColor: AppColors.closed_text,
      );
    case "canceled_by_system":
      return StatusColors(
        badgeColor: ColorMappingImpl().background_error_light,
        textColor: ColorMappingImpl().tag_text_error,
      );
    default:
      return StatusColors(
        badgeColor: ColorMappingImpl().borderNeutralPrimary,
        textColor: ColorMappingImpl().textDisplay,
      );
  }
}
