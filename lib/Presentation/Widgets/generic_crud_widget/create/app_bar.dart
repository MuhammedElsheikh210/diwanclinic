import '../../../../../index/index_main.dart';

class AppBarDealsDetails extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  String? title_download;
  String? icon_download;
  bool? show_support;
  final VoidCallback onDownloadTap;
  final VoidCallback onNavigateTap;

  AppBarDealsDetails({
    Key? key,
    required this.title,
    this.title_download,
    this.icon_download,
    this.show_support,
    required this.onDownloadTap,
    required this.onNavigateTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Text(
        title,
        style: context.typography.smSemiBold.copyWith(
          color: AppColors.textDefault,
        ),
        textAlign: TextAlign.end, // Align text to the right for RTL
      ),
      leading: InkWell(
        onTap: onNavigateTap,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10),
          child: Svgicon(icon: IconsConstants.back_icon),
        ),
      ),
      centerTitle: false,
      actions: [
        // Download Button
        // GestureDetector(
        //   onTap: onDownloadTap,
        //   child: Container(
        //     margin: const EdgeInsets.symmetric(horizontal: 8.0),
        //     padding: const EdgeInsets.symmetric(
        //       horizontal: 12.0,
        //       vertical: 7.0,
        //     ),
        //     decoration: BoxDecoration(
        //       color: AppColors.background_neutral_default,
        //       borderRadius: BorderRadius.circular(5),
        //     ),
        //     child: Row(
        //       children: [
        //         Svgicon(icon: icon_download ?? IconsConstants.downlaod),
        //         const SizedBox(width: 6),
        //         Text(
        //           title_download ?? "تحميل الإتفاقية",
        //           style: context.typography.smMedium.copyWith(
        //             color: AppColors.textDefault,
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
        Visibility(
          visible: show_support == true,
          child: GestureDetector(
            onTap: () {
              print("support icon");
            },
            child: const Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Svgicon(icon: IconsConstants.support),
            ),
          ),
        ),

        // Navigation Button
      ],
      automaticallyImplyLeading: false, // Hide back button if needed
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}
