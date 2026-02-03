import '../../../../../index/index_main.dart';

class ReservationListTileWidget extends StatelessWidget {
  final String title;
  final String body;
  final String icon;

  const ReservationListTileWidget({
    super.key,
    required this.title,
    required this.body,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: ColorMappingImpl().background_neutral_100,
        borderRadius: BorderRadius.circular(15),
      ),
      child: AppLisTile(
        contentPadding: EdgeInsets.zero,
        leading: Svgicon(icon: icon, height: 30.h, width: 30.w),
        title: AppText(
          text: title,
          textStyle: context.typography.mdBold.copyWith(
            color: ColorMappingImpl().textSecondaryParagraph,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: AppText(
            text: body.isNotEmpty ? body : "-",
            textStyle: context.typography.mdBold.copyWith(
              color: ColorMappingImpl().textDisplay,
            ),
          ),
        ),
      ),
    );
  }
}
