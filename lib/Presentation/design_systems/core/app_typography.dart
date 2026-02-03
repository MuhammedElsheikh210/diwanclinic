import '../../../index/index_main.dart';

class AppTypography extends ThemeExtension<AppTypography> {
  /// Constructor for AppTypography
  const AppTypography({
    required this.xsBold,
    required this.mdRegular,
    required this.smRegular,
    required this.mdMedium,
    required this.xlBold,
    required this.xsRegular,
    required this.mdBold,
    required this.displaySmBold,
    required this.xsMedium,
    required this.smSemiBold,
    required this.lgBold,
    required this.smMedium,
    required this.xxlBold,
  });

  /// Factory method for light theme typography
  factory AppTypography.light() {
    return AppTypography(
      xsBold: GoogleFonts.getFont(
        Strings.fontname,
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
        height: 32 / 24,
      ),
      mdRegular: GoogleFonts.getFont(
        Strings.fontname,
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
      ),
      smRegular: GoogleFonts.getFont(
        Strings.fontname,
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
      ),
      mdMedium: GoogleFonts.getFont(
        Strings.fontname,
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        height: 24 / 16,
      ),
      xlBold: GoogleFonts.getFont(
        Strings.fontname,
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        height: 30 / 20,
      ),
      xsRegular: GoogleFonts.getFont(
        Strings.fontname,
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        height: 18 / 12,
      ),
      mdBold: GoogleFonts.getFont(
        Strings.fontname,
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        height: 24 / 16,
      ),
      displaySmBold: GoogleFonts.getFont(
        Strings.fontname,
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        height: 20 / 14,
      ),
      xsMedium: GoogleFonts.getFont(
        Strings.fontname,
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        height: 18 / 12,
      ),
      smSemiBold: GoogleFonts.getFont(
        Strings.fontname,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        height: 20 / 14,
      ),
      lgBold: GoogleFonts.getFont(
        Strings.fontname,
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        height: 28 / 18,
      ),
      smMedium: GoogleFonts.getFont(
        Strings.fontname,
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        height: 20 / 14,
      ),
      xxlBold: GoogleFonts.getFont(
        Strings.fontname,
        fontSize: 30.sp, // Use .sp for responsive font size
        fontWeight: FontWeight.w700,
        height: 40 / 30,
      ),
    );
  }

  /// Typography styles
  final TextStyle xsBold;
  final TextStyle mdRegular;
  final TextStyle smRegular;
  final TextStyle mdMedium;
  final TextStyle xlBold;
  final TextStyle xsRegular;
  final TextStyle mdBold;
  final TextStyle displaySmBold;
  final TextStyle xsMedium;
  final TextStyle smSemiBold;
  final TextStyle lgBold;
  final TextStyle smMedium;
  final TextStyle xxlBold;

  @override
  AppTypography copyWith({
    TextStyle? xsBold,
    TextStyle? mdRegular,
    TextStyle? smRegular,
    TextStyle? mdMedium,
    TextStyle? xlBold,
    TextStyle? xsRegular,
    TextStyle? mdBold,
    TextStyle? displaySmBold,
    TextStyle? xsMedium,
    TextStyle? smSemiBold,
    TextStyle? lgBold,
    TextStyle? smMedium,
    TextStyle? xxlBold,
  }) {
    return AppTypography(
      xsBold: xsBold ?? this.xsBold,
      mdRegular: mdRegular ?? this.mdRegular,
      smRegular: smRegular ?? this.smRegular,
      mdMedium: mdMedium ?? this.mdMedium,
      xlBold: xlBold ?? this.xlBold,
      xsRegular: xsRegular ?? this.xsRegular,
      mdBold: mdBold ?? this.mdBold,
      displaySmBold: displaySmBold ?? this.displaySmBold,
      xsMedium: xsMedium ?? this.xsMedium,
      smSemiBold: smSemiBold ?? this.smSemiBold,
      lgBold: lgBold ?? this.lgBold,
      smMedium: smMedium ?? this.smMedium,
      xxlBold: xxlBold ?? this.xxlBold,
    );
  }

  @override
  AppTypography lerp(covariant ThemeExtension<AppTypography>? other, double t) {
    if (other is! AppTypography) return this;

    return AppTypography(
      xsBold: TextStyle.lerp(xsBold, other.xsBold, t)!,
      mdRegular: TextStyle.lerp(mdRegular, other.mdRegular, t)!,
      smRegular: TextStyle.lerp(smRegular, other.smRegular, t)!,
      mdMedium: TextStyle.lerp(mdMedium, other.mdMedium, t)!,
      xlBold: TextStyle.lerp(xlBold, other.xlBold, t)!,
      xsRegular: TextStyle.lerp(xsRegular, other.xsRegular, t)!,
      mdBold: TextStyle.lerp(mdBold, other.mdBold, t)!,
      displaySmBold: TextStyle.lerp(displaySmBold, other.displaySmBold, t)!,
      xsMedium: TextStyle.lerp(xsMedium, other.xsMedium, t)!,
      smSemiBold: TextStyle.lerp(smSemiBold, other.smSemiBold, t)!,
      lgBold: TextStyle.lerp(lgBold, other.lgBold, t)!,
      smMedium: TextStyle.lerp(smMedium, other.smMedium, t)!,
      xxlBold: TextStyle.lerp(xxlBold, other.xxlBold, t)!,
    );
  }
}
