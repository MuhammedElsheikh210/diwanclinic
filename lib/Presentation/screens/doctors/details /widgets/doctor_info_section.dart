import '../../../../../../index/index_main.dart';

class DoctorHeaderWidget extends StatelessWidget {
  final LocalUser doctor;

  const DoctorHeaderWidget({Key? key, required this.doctor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final d = doctor.asDoctor; // ✅ الحل

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // 👇 Profile + Qualification
        Positioned(
          bottom: -50.h,
          right: 10.w,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 👤 Profile Image
              InkWell(
                onTap:
                    () => Get.to(
                      () => FullScreenImageView(
                        imageUrl: doctor.profileImage ?? "",
                      ),
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

              const SizedBox(width: 10),

              // 📄 Qualification
              SizedBox(
                width: ScreenUtil().screenWidth - 140.w,
                child: Text(
                  d?.doctorQualifications ?? "", // ✅ FIX
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.mdBold.copyWith(
                    color: AppColors.background_black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
