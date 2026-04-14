import '../../../../../../../index/index_main.dart';

class PatientInfoSection extends StatelessWidget {
  final ReservationModel reservation;

  const PatientInfoSection({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    // paste your existing _buildPatientInfo logic here
    final transferImage = reservation.transferImage;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 🧍 Patient name and avatar
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: AppLisTile(
              leading: const Svgicon(icon: IconsConstants.avatar),
              title: AppText(
                text: "الحالة",
                textStyle: context.typography.mdBold.copyWith(
                  color: ColorMappingImpl().white,
                ),
              ),
              subtitle: AppText(
                text: reservation.patientName ?? "بدون اسم",
                textStyle: context.typography.lgBold.copyWith(
                  color: ColorMappingImpl().white,
                ),
              ),
            ),
          ),
        ),

        // 💳 Transfer image (only if exists)
        if (transferImage != null && transferImage.isNotEmpty)
          InkWell(
            onTap: () {
              Get.to(
                () => FullScreenImageView(imageUrl: transferImage),
                transition: Transition.fadeIn,
                duration: const Duration(milliseconds: 250),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: transferImage,
                  fit: BoxFit.cover,
                  height: 55.w,
                  width: 85.w,
                  placeholder: (context, url) => Container(
                    color: AppColors.background_neutral_100,
                    child: const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 1.5),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.background_neutral_100,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
