import 'package:diwanclinic/index/index_main.dart';

class HeaderSectionWidget extends StatelessWidget {
  final String title;
  final VoidCallback onMore;

  const HeaderSectionWidget({
    super.key,
    required this.title,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 15.0, left: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// 🔹 Title
          Text(title, style: context.typography.lgBold),

          /// 🔹 View More Button
          InkWell(
            onTap: onMore,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("عرض المزيد", style: context.typography.smMedium),
                const Icon(Icons.arrow_forward_ios, size: 17),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
