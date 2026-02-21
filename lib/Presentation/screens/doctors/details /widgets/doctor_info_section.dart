import '../../../../../../index/index_main.dart';

class DoctorHeaderWidget extends StatelessWidget {
  final LocalUser doctor;

  const DoctorHeaderWidget({Key? key, required this.doctor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // 🖼️ Cover Image
        InkWell(
          onTap: () => Get.to(
            () => FullScreenImageView(imageUrl: doctor.coverImage ?? ""),
          ),
          child: SizedBox(
            height: 250.h,
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl:
                  doctor.coverImage ??
                  "https://via.placeholder.com/800x400?text=No+Cover+Image",
              fit: BoxFit.cover,
              placeholder: (context, _) =>
                  Container(color: Colors.grey.shade200),
              errorWidget: (context, _, __) => Container(
                color: Colors.grey.shade300,
                child: const Icon(Icons.image_not_supported, size: 40),
              ),
            ),
          ),
        ),

        // 👇 Profile Image + Name (Overlapping bottom)
        Positioned(
          bottom: -50.h,
          right: 10.w,
          child: InkWell(
            onTap: () => Get.to(
              () => FullScreenImageView(imageUrl: doctor.profileImage ?? ""),
            ),
            child: Container(
              width: 100.w,
              height: 100.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(
                    doctor.profileImage ??
                        "https://via.placeholder.com/150x150?text=Profile",
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -50.h,
          right: 10.w,
          child: InkWell(
            onTap: () => Get.to(
              () => FullScreenImageView(imageUrl: doctor.profileImage ?? ""),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 100.w,
                  height: 100.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(
                        doctor.profileImage ??
                            "https://via.placeholder.com/150x150?text=Profile",
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: ScreenUtil().screenWidth - 140.w,
                  child: Text(
                    doctor.doctorQualifications ?? "",
                    maxLines: 2,
                    style: context.typography.mdBold.copyWith(
                      color: AppColors.background_black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
