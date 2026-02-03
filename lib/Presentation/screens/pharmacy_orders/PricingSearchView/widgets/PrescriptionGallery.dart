import '../../../../../index/index_main.dart';

class PrescriptionGallery extends StatefulWidget {
  final List<String> images;

  const PrescriptionGallery(this.images, {super.key});

  @override
  State<PrescriptionGallery> createState() => _PrescriptionGalleryState();
}

class _PrescriptionGalleryState extends State<PrescriptionGallery> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.images.where((e) => e.trim().isNotEmpty).toList();

    if (images.isEmpty) {
      return _EmptyPrescription();
    }

    return Stack(
      children: [
        // ───────── PageView ─────────
        PageView.builder(
          controller: _controller,
          itemCount: images.length,
          onPageChanged: (i) {
            setState(() => currentIndex = i);
          },
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => Get.to(
                () => FullScreenGalleryView(
                  imageUrls: images,
                  initialIndex: index,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _PrescriptionPlaceholder(),
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  },
                ),
              ),
            );
          },
        ),

        // ───────── Counter (1 / N) ─────────
        Positioned(
          top: 24,
          right: 24,
          child: _CounterBadge(current: currentIndex + 1, total: images.length),
        ),

        // ───────── Dots Indicator ─────────
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: _DotsIndicator(
            count: images.length,
            currentIndex: currentIndex,
          ),
        ),
      ],
    );
  }
}

class _PrescriptionPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background_neutral_25,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.receipt_long,
            size: 48,
            color: AppColors.textSecondaryParagraph,
          ),
          const SizedBox(height: 8),
          Text("لا توجد صورة", style: context.typography.smRegular),
        ],
      ),
    );
  }
}

class _CounterBadge extends StatelessWidget {
  final int current;
  final int total;

  const _CounterBadge({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "$current / $total",
        style: context.typography.smMedium.copyWith(color: Colors.white),
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;

  const _DotsIndicator({required this.count, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == currentIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 18 : 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}

class _EmptyPrescription extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background_neutral_25,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderNeutralPrimary),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.receipt_long,
              size: 48,
              color: AppColors.textSecondaryParagraph,
            ),
            const SizedBox(height: 8),
            Text(
              "لا توجد صور للروشتة",
              style: context.typography.mdMedium.copyWith(
                color: AppColors.textSecondaryParagraph,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
