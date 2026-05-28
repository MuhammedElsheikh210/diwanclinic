import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../../index/index_main.dart';

class MarketingBannerWidget extends StatefulWidget {
  const MarketingBannerWidget({super.key});

  @override
  State<MarketingBannerWidget> createState() => _MarketingBannerWidgetState();
}

class _MarketingBannerWidgetState extends State<MarketingBannerWidget> {
  List<String> _imageUrls = [];
  int _currentIndex = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchBanners();
  }

  Future<void> _fetchBanners() async {
    try {
      final ref = FirebaseDatabase.instance.ref(ApiConstatns.marketingBanners);
      final snapshot = await ref.get();

      if (!snapshot.exists) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      final urls = <String>[];
      final data = snapshot.value;

      if (data is Map) {
        for (final entry in data.values) {
          if (entry is Map) {
            final url = entry['imageUrl']?.toString();
            if (url != null && url.isNotEmpty) urls.add(url);
          }
        }
      } else if (data is List) {
        for (final entry in data) {
          if (entry is Map) {
            final url = entry['imageUrl']?.toString();
            if (url != null && url.isNotEmpty) urls.add(url);
          }
        }
      }

      if (mounted) {
        setState(() {
          _imageUrls = urls;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return _buildShimmer();
    if (_imageUrls.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: _imageUrls.length,
          options: CarouselOptions(
            height: 195.h,
            viewportFraction: 0.92,
            enableInfiniteScroll: _imageUrls.length > 1,
            autoPlay: _imageUrls.length > 1,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 600),
            autoPlayCurve: Curves.easeInOut,
            enlargeCenterPage: true,
            enlargeFactor: 0.15,
            onPageChanged: (index, _) => setState(() => _currentIndex = index),
          ),
          itemBuilder: (context, index, _) {
            return _BannerCard(imageUrl: _imageUrls[index]);
          },
        ),
        if (_imageUrls.length > 1) ...[
          SizedBox(height: 10.h),
          _DotsIndicator(count: _imageUrls.length, current: _currentIndex),
        ],
      ],
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: 160.h,
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final String imageUrl;

  const _BannerCard({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder:
            (_, __) => Shimmer.fromColors(
              baseColor: Colors.grey.shade200,
              highlightColor: Colors.grey.shade100,
              child: Container(color: Colors.white),
            ),
        errorWidget:
            (_, __, ___) => Container(
              color: AppColors.primary.withOpacity(0.08),
              child: Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.primary.withOpacity(0.4),
                  size: 36.sp,
                ),
              ),
            ),
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  final int count;
  final int current;

  const _DotsIndicator({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          width: isActive ? 18.w : 6.w,
          height: 6.h,
          decoration: BoxDecoration(
            color:
                isActive
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.25),
            borderRadius: BorderRadius.circular(4.r),
          ),
        );
      }),
    );
  }
}
