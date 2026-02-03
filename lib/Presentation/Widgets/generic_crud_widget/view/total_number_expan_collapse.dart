import '../../../../index/index_main.dart';

class TotalNumberExpandCollapseCard extends StatefulWidget {
  final double total;
  final String title;
  final String sub_title;

  const TotalNumberExpandCollapseCard({
    Key? key,
    required this.total,
    required this.title,
    required this.sub_title,
  }) : super(key: key);

  @override
  State<TotalNumberExpandCollapseCard> createState() =>
      _TotalNumberExpandCollapseCardState();
}

class _TotalNumberExpandCollapseCardState
    extends State<TotalNumberExpandCollapseCard> {
  @override
  Widget build(BuildContext context) {
    final colors = ColorMappingImpl();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 17.h),
      margin: EdgeInsets.only(left: 10.w, right: 10.w, bottom: 8.h, top: 5.h),
      decoration: BoxDecoration(
        color: colors.primaryButtonDefault,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: context.typography.mdBold.copyWith(
                    color: colors.primaryTextButton,
                  ),
                ),
                SizedBox(height: 7.h),
                Text(
                  widget.sub_title,
                  style: context.typography.xsRegular.copyWith(
                    color: colors.primaryTextButton.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          // Total agreements count
          Text(
            widget.total.toStringAsFixed(2),
            style: context.typography.xxlBold.copyWith(
              color: colors.primaryTextButton,
            ),
          ),
        ],
      ),
    );
  }
}
