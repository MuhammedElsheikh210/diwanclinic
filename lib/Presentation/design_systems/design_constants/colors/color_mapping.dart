import 'dart:ui';

abstract class ColorMapping {
  // Existing mappings
  Color get labelTextColor;

  Color get hintTextColor;

  Color get focusedTextColor;

  Color get errorTextColor;

  Color get disabledTextColor;

  Color get borderDefault;

  Color get borderFocused;

  Color get borderError;

  Color get borderDisabled;

  Color get backgroundDefault;

  Color get backgroundFocused;

  Color get backgroundDisabled;

  // Button Colors
  Color get primaryButtonDefault;

  Color get primaryButtonFocused;

  Color get primaryButtonEnabled;

  Color get primaryTextButton;

  Color get buttonDisableColor;

  Color get buttonDisabledTextColor;

  Color get secondaryButtonText;

  Color get secondaryButtonDefault;

  Color get secondaryButtonHover;

  Color get secondaryButtonFocused;

  Color get secondaryButtonEnabled;

  Color get outlineButtonText;

  Color get outlineButtonDefault;

  Color get outlineButtonHover;

  Color get outlineButtonFocused;

  Color get outlineButtonEnabled;

  // Border Colors
  Color get borderNeutralPrimary;

  // New Colors
  Color get textDisplay;

  Color get textSecondaryParagraph;

  Color get textLabel;

  Color get white;

  Color get textDefault;

  //button background
  Color get background_black_default;

  Color get background_neutral_default;

  Color get background_warning_light;

  Color get background_error_light;

  Color get tag_icon_warning;

  Color get tag_text_error;

  Color get background_neutral_100;

  Color get field_text_placeholder;
}
