import '../../../../index/index_main.dart';

class AnalysisNumberExpandCollapseCard extends StatefulWidget {
  final int total;
  final String title;
  final String sub_title;
  final List<StatusItem>? status;
  final Function(bool isExpanded)? onToggle; // Callback for toggle action

  const AnalysisNumberExpandCollapseCard({
    Key? key,
    required this.total,
    required this.title,
    required this.sub_title,
    this.status,
    this.onToggle,
  }) : super(key: key);

  @override
  State<AnalysisNumberExpandCollapseCard> createState() =>
      _AnalysisNumberExpandCollapseCardState();
}

class _AnalysisNumberExpandCollapseCardState
    extends State<AnalysisNumberExpandCollapseCard> {
  bool isExpanded = true;

  void toggleExpansion() {
    setState(() {
      isExpanded = !isExpanded;
    });
    widget.onToggle?.call(isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final colors = ColorMappingImpl();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
      margin: EdgeInsets.symmetric(horizontal: 13.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: colors.primaryButtonDefault,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    // Total agreements count
                    Text(
                      widget.total.toString(),
                      style: context.typography.xxlBold.copyWith(
                        color: colors.primaryTextButton,
                      ),
                    ),
                    SizedBox(width: 15.w),
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
                          SizedBox(height: 5.h),
                          Text(
                            widget.sub_title,
                            style: context.typography.xsRegular.copyWith(
                              color: colors.primaryTextButton.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow to expand/collapse
              InkWell(
                onTap: toggleExpansion,
                child: AnimatedRotation(
                  turns: isExpanded ? 0 : 0.5,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(Icons.keyboard_arrow_down, color: colors.white),
                ),
              ),
            ],
          ),
          if (isExpanded)
            Column(
              children: [
                SizedBox(height: 10.h),
                const Divider(color: AppColors.textFieldBorderDefault),
                _buildStatisticsGrid(context),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2,
        crossAxisSpacing: 20,
      ),
      itemCount: widget.status?.length ?? 0,
      itemBuilder: (context, index) {
        return _buildStatisticItem(context, status: widget.status?[index]);
      },
    );
  }

  Widget _buildStatisticItem(
    BuildContext context, {
    required StatusItem? status,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          status?.title ?? "",
          style: context.typography.xsMedium.copyWith(
            color: ColorMappingImpl().primaryTextButton.withValues(alpha: 0.8),
          ),
        ),
        SizedBox(height: 5.h),
        Expanded(
          child: Text(
            "${status?.count.toString() ?? ""} ج.م",
            style: context.typography.smSemiBold.copyWith(
              color: ColorMappingImpl().primaryTextButton,
            ),
          ),
        ),
      ],
    );
  }
}

class StatusItem {
  final String title;
  final String count;

  StatusItem({required this.title, required this.count});
}
