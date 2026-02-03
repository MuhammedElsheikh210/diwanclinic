import '../../../../index/index.dart';

class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary10 = Color(0xFFE8F5E9);
  static const Color primary20 = Color(0xFFC0E0D5);
  static const Color primary40 = Color(0xFF8FC4BA);
  static const Color primary60 = Color(0xFF5FA19A);
  static const Color primary_faint = Color(0xFFE7FCEA);
  static const Color primary80 = Color(0xFF185F59); // Primary 80
  static const Color primary = Color(0xFF1B8354);
  static const Color primary_light = Color(0xFFECFDF3);
  static const Color background = Color(0xFFE7FCEA);

  static const Color stepper_button_upcomming = Color(0xFFD2D6DB);

  // Secondary Colors
  static const Color secondary10 = Color(0xFFF0E7DF);
  static const Color secondary20 = Color(0xFFE2D6C7);
  static const Color secondary40 = Color(0xFFC2B3A3);
  static const Color secondary60 = Color(0xFFA98C70);
  static const Color secondary80 = Color(0xFFA98C70); // Duplicate clarified
  static const Color secondary100 = Color(0xFFA98C70);

  // Success Colors
  static const Color successBackground = Color(0xFFE8F5E9); // Light Green
  static const Color successForeground = Color(0xFF4CAF50); // Success Green

  // Error Colors
  static const Color errorBackground = Color(0xFFFEF3F3); // Light Red
  static const Color errorForeground = Color(0xFFF14837); // Error Red

  // Divider and Lines
  static const Color dividerAndLines = Color(
    0xFFE0E0E2,
  ); // Grayscale Light Lines

  // Background Colors
  static const Color backgroundPrimary = Color(
    0xFF161616,
  ); // Background primary
  static const Color backgroundSecondary = Color(
    0xFF6C737F,
  ); // Background secondary

  // Blue Colors
  static const Color blueLightBackground = Color(0xFFD0E8FF); // Light Blue
  static const Color blueForeground = Color(0xFF4A90E2); // Blue Foreground

  // Yellow Colors
  static const Color yellowBackground = Color(0xFFFFFBCF);
  static const Color yellowForeground = Color(0xFFF2BF12);
  static const Color teal = Color(0xFF00A2B8);

  // Grayscale Colors
  static const Color grayLight = Color(0xFFE0E0E2); // Light gray lines
  static const Color grayMedium = Color(0xFF8C8C8C); // Medium gray
  static const Color buttonDisabledTextColor = Color(0xFF9DA4AE); // Medium gray
  static const Color buttonDisabledColor = Color(0xFF9DA4AE); // Medium gray
  static const Color buttonpressedColor = Color(0xFF4D5761); // Medium gray

  // Shadow Settings
  static const Color shadowUpper = Color(0xFF8F8F8F);
  static const double shadowOpacity = 0.2;
  static const double shadowBlur = 20.0;
  static const double shadowOffsetX = 0.0;
  static const double shadowOffsetY = -4.0;

  // Gradients
  static const Gradient greenGradient = LinearGradient(
    colors: [Color(0xFFC7DAB4), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Gradient goldGradient = LinearGradient(
    colors: [Color(0xFFF9EAD7), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // colors
  // Text Colors
  static const Color textDisplay = Color(0xFF1F2A37); // Text/text-display
  static const Color textSecondaryParagraph = Color(
    0xFF6C737F,
  ); // Text/text-secondary-paragraph
  static const Color formFieldTextLabel = Color(
    0xFF161616,
  ); // Form/field-text-label
  static const Color white = Color(0xFFFFFFFF); // Text/text-oncolor-primary
  static const Color textDefault = Color(0xFF161616);
  static const Color text_steeper = Color(0xFF384250);

  static const Color textFieldPlaceholder = Color(
    0xFF6C737F,
  ); // Text/text-default
  static const Color textFieldBorderDefault = Color(0xFF9DA4AE); // Medium gray
  static const Color textFieldBorderFocused = Color(0xFF0D121C); // Medium gray
  static const Color textFieldBackgroundFocused = Color(0xFFF3F4F6);
  static const Color borderNeutralPrimary = Color(0xFFD2D6DB);
  static const Color textFormTitle = Color(0xFF161616);

  static const Color backgroundBlackDefault = Color(0xFF0D121C);

  static const Color background_neutral_default = Color(0xFFF3F4F6);

  static const Color background_warning_light = Color(0xFFFFFAEB);

  static const Color background_error_light = Color(0xFFFEF3F2);

  static const Color tag_icon_warning = Color(0xFF93370D);

  static const Color tag_text_error = Color(0xFF912018);
  static const Color background_neutral_100 = Color(0xFFF3F4F6);
  static const Color background_neutral_25 = Color(0xFFFCFCFD);
  static const Color field_text_placeholder = Color(0xFF6C737F);
  static const Color background_neutral_800 = Color(0xFF1F2A37);
  static const Color background_black = Color(0xFF161616);
  static const Color text_primary_paragraph = Color(0xFF384250);
  static const Color background_info_50 = Color(0xFFEFF8FF);
  static const Color text_info = Color(0xFF175CD3);
  static const Color background_primary_default = Color(0xFF1B8354);

  // badge

  static const Color closed_background = Color(0xFFB54708);
  static const Color closed_text = Color(0xFFB54708);
  static const Color pending = Color(0xFF1570EF);
  static const Color not_start = Color(0xFFFFB300);
}
