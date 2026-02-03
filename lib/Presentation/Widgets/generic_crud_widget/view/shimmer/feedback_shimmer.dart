import '../../../../../index/index_main.dart';

class ShimmerFeedbackLoader extends StatelessWidget {
  const ShimmerFeedbackLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      itemCount: 3, // عدد الكروت الوهمية
      itemBuilder: (context, index) {
        return Container(
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
              // 🔹 Patient Name + Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildShimmerBox(height: 16.h, width: 120.w), // Patient Name
                  _buildShimmerBox(height: 14.h, width: 80.w), // Date
                ],
              ),
              SizedBox(height: 12.h),

              // 🔹 Comment
              _buildShimmerBox(height: 14.h, width: double.infinity),
              SizedBox(height: 6.h),
              _buildShimmerBox(
                height: 14.h,
                width: MediaQuery.of(context).size.width * 0.6,
              ),

              SizedBox(height: 12.h),

              // 🔹 Rating Stars
              Row(
                children: List.generate(
                  5,
                  (i) => Padding(
                    padding: EdgeInsets.only(right: 4.w),
                    child: _buildShimmerBox(height: 18.h, width: 18.h),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerBox({required double height, required double width}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(6.r),
        ),
      ),
    );
  }
}
