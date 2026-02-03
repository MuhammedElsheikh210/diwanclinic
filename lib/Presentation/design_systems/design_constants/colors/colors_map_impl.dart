import '../../../../index/index.dart';

class ColorMappingImpl implements ColorMapping {
  @override
  Color get labelTextColor => AppColors.textFieldPlaceholder;

  @override
  Color get hintTextColor => AppColors.textFieldPlaceholder;

  @override
  Color get focusedTextColor => AppColors.formFieldTextLabel;

  @override
  Color get errorTextColor => AppColors.errorForeground;

  @override
  Color get disabledTextColor => AppColors.grayMedium;

  @override
  Color get borderDefault => AppColors.textFieldBorderDefault;

  @override
  Color get borderFocused => AppColors.textFieldBorderFocused;

  @override
  Color get borderError => AppColors.errorForeground;

  @override
  Color get borderDisabled => AppColors.grayLight;

  @override
  Color get backgroundDefault => AppColors.white;

  @override
  Color get backgroundFocused => AppColors.textFieldBackgroundFocused;

  @override
  Color get backgroundDisabled => AppColors.grayLight;

  // Button Colors
  @override
  Color get primaryButtonDefault => AppColors.primary;

  @override
  Color get primaryButtonFocused => AppColors.buttonpressedColor;

  @override
  Color get primaryButtonEnabled => AppColors.primary;

  @override
  Color get primaryTextButton => AppColors.white;

  @override
  Color get buttonDisableColor => AppColors.buttonDisabledColor;

  @override
  Color get buttonDisabledTextColor => AppColors.buttonDisabledTextColor;

  @override
  Color get secondaryButtonText => AppColors.primary;

  @override
  Color get secondaryButtonDefault => AppColors.secondary10;

  @override
  Color get secondaryButtonHover => AppColors.secondary20;

  @override
  Color get secondaryButtonFocused => AppColors.secondary40;

  @override
  Color get secondaryButtonEnabled => AppColors.primary80;

  @override
  Color get outlineButtonText => AppColors.primary;

  @override
  Color get outlineButtonDefault => AppColors.primary.withOpacity(0.4);

  @override
  Color get outlineButtonHover => AppColors.primary.withOpacity(0.6);

  @override
  Color get outlineButtonFocused => AppColors.primary.withOpacity(0.8);

  @override
  Color get outlineButtonEnabled => AppColors.primary.withOpacity(0.2);

  @override
  Color get borderNeutralPrimary => AppColors.borderNeutralPrimary;

  // New Colors
  @override
  Color get textDisplay => AppColors.textDisplay;

  @override
  Color get textSecondaryParagraph => AppColors.textSecondaryParagraph;

  @override
  Color get textLabel => AppColors.formFieldTextLabel;

  @override
  Color get white => AppColors.white;

  @override
  Color get textDefault => AppColors.textDefault;

  @override
  Color get background_black_default => AppColors.backgroundBlackDefault;



  @override
  Color get background_error_light => AppColors.background_error_light;

  @override
  Color get background_neutral_default => AppColors.background_neutral_default;

  @override
  Color get background_warning_light => AppColors.background_warning_light;

  @override
  Color get tag_icon_warning => AppColors.tag_icon_warning;

  @override
  Color get tag_text_error => AppColors.tag_text_error;

  @override
  // TODO: implement background_neutral_100
  Color get background_neutral_100 => AppColors.background_neutral_100;

  @override
  // TODO: implement field_text_placeholder
  Color get field_text_placeholder => AppColors.field_text_placeholder;
}
