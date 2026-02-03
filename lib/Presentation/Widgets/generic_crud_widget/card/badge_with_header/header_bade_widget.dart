import '../../../../../../../index/index_main.dart';

class HeaderWidget extends StatelessWidget {
  final String name;
  final String? status_name;
  final String? status_label;
  final String? title;
  final int? dateTimeStamp;

  const HeaderWidget({
    Key? key,
    required this.name,
    this.status_name,
    this.status_label,
    this.dateTimeStamp,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorMappingImpl().background_neutral_100,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.r),
          topRight: Radius.circular(25.r),
        ),
        boxShadow: AppShadow.deals_cart_top_shadow,
      ),
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              AppText(
                text: title ?? "",
                textStyle: context.typography.xsRegular.copyWith(
                  color: ColorMappingImpl().textSecondaryParagraph,
                ),
              ),
              SizedBox(width: 5.w),
              AppText(
                text: name,
                textStyle: context.typography.mdBold.copyWith(
                  color: ColorMappingImpl().textDisplay,
                ),
              ),
            ],
          ),
          // Status Badge
          Visibility(
            visible: status_name != null,
            child: StatusBadge(
              status: status_name?.toLowerCase() ?? "",
              label: status_label ?? "",
              dateTimeStamp: dateTimeStamp ?? 0,
            ),
          ),
        ],
      ),
    );
  }
}
