import '../../../../index/index_main.dart';

class BottomSheetAppBar extends StatelessWidget {
  final String title;

  const BottomSheetAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                title,
                style: context.typography.mdBold.copyWith(
                  color: AppColors.textFormTitle,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () => Get.back(),
            child: const Svgicon(icon: IconsConstants.Button_Close),
          ),
        ],
      ),
    );
  }
}
