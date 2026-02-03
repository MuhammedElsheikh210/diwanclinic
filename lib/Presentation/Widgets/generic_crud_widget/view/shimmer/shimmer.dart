import '../../../../../index/index_main.dart';
import 'shimmer_header.dart'; // Import the new ShimmerHeader

class ShimmerLoader extends StatelessWidget {
  const ShimmerLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 7, // 1 for ShimmerHeader + 6 for normal placeholders
      itemBuilder: (context, index) {
        if (index == 0) {
          return const ShimmerHeader(); // Use the ShimmerHeader at index 0
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          padding: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header (Agreement Number & Status)
              _buildShimmerHeader(),
              const SizedBox(height: 10),

              // Market Section
              _buildShimmerListTile(),
              const SizedBox(height: 10),

              // Farmer Section
              _buildShimmerListTile(),
              const SizedBox(height: 10),

              // Start and End Dates
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    _buildShimmerBox(
                      height: 40,
                      width: MediaQuery.of(context).size.width * 0.4,
                    ),
                    const SizedBox(width: 10),
                    _buildShimmerBox(
                      height: 40,
                      width: MediaQuery.of(context).size.width * 0.4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Three Buttons
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Expanded(child: _buildShimmerButton()),
                    const SizedBox(width: 10),
                    Expanded(child: _buildShimmerButton()),
                    const SizedBox(width: 10),
                    _buildShimmerBox(height: 44, width: 47), // Icon Button
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Header shimmer placeholder
  Widget _buildShimmerHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildShimmerBox(height: 15, width: 100), // Agreement Number
          _buildShimmerBox(height: 25, width: 60), // Status Badge
        ],
      ),
    );
  }

  // ListTile-like shimmer placeholder
  Widget _buildShimmerListTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        children: [
          _buildShimmerBox(height: 40, width: 40), // Icon
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShimmerBox(height: 15, width: 100), // Title
              const SizedBox(height: 5),
              _buildShimmerBox(height: 15, width: 150), // Subtitle
            ],
          ),
        ],
      ),
    );
  }

  // Shimmer button placeholder
  Widget _buildShimmerButton() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  // General shimmer box
  Widget _buildShimmerBox({required double height, required double width}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}
