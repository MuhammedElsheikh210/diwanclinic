import '../../../../../index/index_main.dart';

class PrescriptionImage extends StatelessWidget {
  final String imageUrl;

  const PrescriptionImage({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(
              () => FullScreenImageView(
            imageUrl: imageUrl,
          ),
        );
      },

      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),

        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          width: 110,
          height: 90,
        ),
      ),
    );
  }
}