import '../../../../../index/index_main.dart';

class ShimmerHeader extends StatelessWidget {
  const ShimmerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = ColorMappingImpl();

    return Shimmer.fromColors(
      baseColor: colors.background_neutral_default,
      highlightColor: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simulated title
          Container(
            width: 150.w,
            height: 20.h,
            margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),

          // Simulated subtitle
          Container(
            width: 250.w,
            height: 14.h,
            margin: EdgeInsets.only(left: 15.w, bottom: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),

          // Simulated TotalNumberExpandCollapseCard
          Container(
            height: 60.h,
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
        ],
      ),
    );
  }
}
