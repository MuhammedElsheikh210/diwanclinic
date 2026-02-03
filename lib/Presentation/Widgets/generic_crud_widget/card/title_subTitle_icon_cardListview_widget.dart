import '../../../../index/index_main.dart';

class MerchantListTileWidget extends StatelessWidget {
  final String title;
  final String body;
  final String icon;
  final bool showTrailing;
  final bool showLeading;

  const MerchantListTileWidget({
    Key? key,
    required this.title,
    required this.body,
    required this.icon,
    this.showTrailing = false,
    this.showLeading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: ColorMappingImpl().background_neutral_100,
        borderRadius: BorderRadius.circular(15),
      ),
      child: AppLisTile(
        contentPadding: EdgeInsets.zero,

        /// **Leading Icon (Optional)**
        leading:
            showLeading ? Svgicon(icon: icon, width: 25, height: 25) : null,

        /// **Trailing Icon (Optional)**
        trailing:
            showTrailing
                ? Svgicon(icon: icon, width: 25, height: 25)
                : const SizedBox(),

        /// **Title Text**
        title: AppText(
          text: title,
          textStyle: context.typography.xsRegular.copyWith(
            color: ColorMappingImpl().textSecondaryParagraph,
            fontSize: 14,
          ),
        ),

        /// **Subtitle Text**
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: AppText(
            text: body,
            textStyle: context.typography.displaySmBold.copyWith(
              color: ColorMappingImpl().textDisplay,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
