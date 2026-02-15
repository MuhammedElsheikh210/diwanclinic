import '../../../../../../index/index_main.dart';

class ReservationCardTransferImage extends StatelessWidget {
  final String imageUrl;

  const ReservationCardTransferImage({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(
              () => FullScreenImageView(imageUrl: imageUrl),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 250),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            height: 55.w,
            width: 85.w,
            placeholder: (_, __) => Container(
              height: 55.w,
              width: 85.w,
              color: AppColors.background_neutral_100,
              child: const Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 1.5),
                ),
              ),
            ),
            errorWidget: (_, __, ___) => Container(
              height: 55.w,
              width: 85.w,
              color: AppColors.background_neutral_100,
              child: const Icon(
                Icons.broken_image,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
