import '../../../../index/index_main.dart';

class HeaderWithFiler extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? filterIcon;
  final VoidCallback? onFilterTap;

  const HeaderWithFiler({
    Key? key,
    required this.title,
    required this.subtitle,
    this.filterIcon = Icons.filter_list, // Default filter icon
    this.onFilterTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = ColorMappingImpl();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Title and Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: context.typography.xlBold.copyWith(
                    color: colors.textDisplay,
                  ),
                ),
                const SizedBox(height: 4),
                // Subtitle
                Text(subtitle, style: context.typography.mdBold.copyWith()),
              ],
            ),
          ),

          // Filter Button
          InkWell(
            onTap: onFilterTap,
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: colors.background_neutral_default,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(Images.filter),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}
