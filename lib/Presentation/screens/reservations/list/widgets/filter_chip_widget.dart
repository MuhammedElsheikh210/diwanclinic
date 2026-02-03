import '../../../../../index/index_main.dart';

class FilterChipWidget extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const FilterChipWidget({
    super.key,
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorResources.COLOR_primary_faint,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorResources.COLOR_Background_Border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: context.typography.smMedium.copyWith(
              color: ColorResources.COLOR_BLACK,
            ),
          ),
          SizedBox(width: 5.w),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 16,
              color: ColorResources.COLOR_GrayDark,
            ),
          ),
        ],
      ),
    );
  }
}
