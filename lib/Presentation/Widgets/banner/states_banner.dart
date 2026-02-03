import '../../../index/index_main.dart';

class StatsBanner extends StatelessWidget {
  final String? title; // optional
  final List<StatsBannerItem> items;
  final String currency;

  /// Optional behavior for default wallet
  final int isDefault;
  final int is_resvere;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const StatsBanner({
    Key? key,
    this.title,
    required this.items,
    this.currency = "ج.م",
    this.isDefault = 0,
    this.is_resvere = 0,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  Widget _statChip(BuildContext context, StatsBannerItem item) {
    return Column(
      children: [
        Text(
          item.title,
          style: context.typography.mdMedium.copyWith(
            color: isDefault == 1 ? AppColors.primary : AppColors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          is_resvere == 1
              ? item.value.toStringAsFixed(0)
              : "${item.value.toStringAsFixed(2)} $currency",
          style: context.typography.lgBold.copyWith(
            color: isDefault == 1 ? AppColors.primary : AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _vertDiv() {
    return Container(
      height: 30,
      width: 1,
      color: isDefault == 1
          ? AppColors.primary.withOpacity(0.4)
          : Colors.white.withOpacity(0.6),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDefault == 1 ? AppColors.grayLight : AppColors.primary80,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDefault == 1 ? AppColors.primary : Colors.transparent,
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 Title Row (optional + edit/delete actions)
          if (title != null ||
              (isDefault == 0 && (onEdit != null || onDelete != null)))
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: context.typography.lgBold.copyWith(
                      color: isDefault == 1
                          ? AppColors.primary
                          : AppColors.white,
                    ),
                  ),

                if (isDefault == 0)
                  if (onEdit != null)
                    InkWell(
                      onTap: onEdit,
                      child: Svgicon(
                        icon: IconsConstants.filter,
                        height: 25.h,
                        width: 25.w,
                        color: AppColors.white,
                      ),
                    ),
              ],
            ),

          /// 🔹 Stats Row
          Padding(
            padding:  EdgeInsets.only(top: 20.0.h,bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length * 2 - 1, (i) {
                if (i.isOdd) return _vertDiv();
                return _statChip(context, items[i ~/ 2]);
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class StatsBannerItem {
  final String title;
  final double value;

  StatsBannerItem({required this.title, required this.value});
}
