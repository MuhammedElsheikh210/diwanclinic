// ------------------------------------------------------------
// Tab Item
// ------------------------------------------------------------
import '../../../../../index/index_main.dart';

class TabItem extends StatelessWidget {
  final String label;

  final bool isSelected;

  final VoidCallback onTap;

  const TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),

          alignment: Alignment.center,

          decoration: BoxDecoration(
            color: isSelected ? AppColors.white : Colors.transparent,

            borderRadius: BorderRadius.circular(8.r),
          ),

          child: Text(
            label,

            style: context.typography.mdMedium.copyWith(
              color:
              isSelected
                  ? AppColors.primary
                  : AppColors.textSecondaryParagraph,
            ),
          ),
        ),
      ),
    );
  }
}
