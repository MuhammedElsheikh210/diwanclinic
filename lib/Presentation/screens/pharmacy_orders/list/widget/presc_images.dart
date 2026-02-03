import '../../../../../index/index_main.dart';

class PrescriptionShowGallery extends StatelessWidget {
  final List<String> images;

  const PrescriptionShowGallery({required this.images});

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Container(
        height: 80.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.background_neutral_25,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderNeutralPrimary),
        ),
        child: AppText(
          text: "لا توجد صور للروشتة",
          textStyle: context.typography.smRegular.copyWith(
            color: AppColors.textSecondaryParagraph,
          ),
        ),
      );
    }

    return SizedBox(
      height: 90.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Get.to(
                () => PrescriptionImageViewer(images: images, index: index),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                images[index],
                width: 90.w,
                height: 90.h,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}

class PrescriptionImageViewer extends StatelessWidget {
  final List<String> images;
  final int index;

  const PrescriptionImageViewer({required this.images, required this.index});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PageView.builder(
        controller: PageController(initialPage: index),
        itemCount: images.length,
        itemBuilder: (_, i) {
          return InteractiveViewer(
            child: Image.network(images[i], fit: BoxFit.contain),
          );
        },
      ),
    );
  }
}
