import '../../../../../index/index_main.dart';

class ShimmerIncomeLoader extends StatelessWidget {
  const ShimmerIncomeLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 12.w),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.borderNeutralPrimary, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBox(height: 18, width: 180),
                SizedBox(height: 10.h),
                _buildBox(height: 14, width: 120),
                SizedBox(height: 10.h),
                _buildBox(height: 18, width: 150),
                SizedBox(height: 10.h),
                _buildBox(height: 14, width: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBox({required double height, required double width}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(6.r),
      ),
    );
  }
}
