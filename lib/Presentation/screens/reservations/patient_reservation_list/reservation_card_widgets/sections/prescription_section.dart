import '../../../../../../../index/index_main.dart';

class PrescriptionSection extends StatelessWidget {
  final ReservationModel reservation;
  final ReservationPatientViewModel controller;
  final bool? showImage; // true = view only | false = allow editing

  const PrescriptionSection({
    super.key,
    required this.reservation,
    required this.controller,
    this.showImage,
  });

  @override
  Widget build(BuildContext context) {
    final images = <String>[
      if (reservation.prescriptionUrl1?.isNotEmpty == true)
        reservation.prescriptionUrl1!,
      if (reservation.prescriptionUrl2?.isNotEmpty == true)
        reservation.prescriptionUrl2!,
    ];

    final isCompleted = reservation.status == ReservationStatus.completed.value;
    
    

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: ColorMappingImpl().background_neutral_100,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: "الروشتة",
              textStyle: context.typography.mdBold.copyWith(
                color: ColorMappingImpl().textSecondaryParagraph,
              ),
            ),
            const SizedBox(height: 5),

            // -------------------------------------------------------------
            // 📌 لا يوجد صور & الحالة Completed → زر تحميل الروشتة
            // -------------------------------------------------------------

            if (images.isEmpty && isCompleted)
              GestureDetector(
                onTap: () {
                  // لو فقط عرض → لا تفتح شيت
                  if (showImage == true) return;

                  controller.openPrescriptionBottomSheet(
                    context: context,
                    reservation: reservation,
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(top: 5.h),
                  height: 45.h,
                  decoration: BoxDecoration(
                    color: AppColors.background_neutral_100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.upload_file, color: AppColors.primary),
                        SizedBox(width: 8.w),
                        Text(
                          'تحميل الروشتة',
                          style: context.typography.mdMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            // -------------------------------------------------------------
            // 📌 لا يوجد صور & الحالة ليست Completed → نص إرشادي
            // -------------------------------------------------------------
            else if (images.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: 5.h),
                child: Text(
                  'ستقوم بتصوير الروشتة بعد انتهاء الكشف',
                  style: context.typography.smRegular.copyWith(
                    color: AppColors.textSecondaryParagraph,
                  ),
                ),
              )
            // -------------------------------------------------------------
            // 📌 يوجد صور → عرض الصور
            // -------------------------------------------------------------
            else
              SizedBox(
                height: 80.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  separatorBuilder: (_, __) => SizedBox(width: 8.w),
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () {
                      if (showImage == true) {
                        // عرض فقط → fullscreen
                        Get.to(() => FullScreenImageView(imageUrl: images[i]));
                      } else {
                        // تعديل الصور
                        controller.openPrescriptionBottomSheet(
                          context: context,
                          reservation: reservation,
                        );
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: images[i],
                        fit: BoxFit.cover,
                        height: 70.h,
                        width: 100.w,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
