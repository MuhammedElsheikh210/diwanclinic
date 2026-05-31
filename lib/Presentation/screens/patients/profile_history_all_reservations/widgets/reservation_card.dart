import '../../../../../index/index_main.dart';

import 'empty_prescription.dart';
import 'prescription_image.dart';

class ReservationHistoryCard extends StatelessWidget {
  final ReservationModel reservation;

  final MedicalRecordModel? medicalRecord;

  final bool isInitiallyExpanded;

  const ReservationHistoryCard({
    super.key,
    required this.reservation,
    required this.medicalRecord,
    this.isInitiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final prescriptions = <String>[
      if (reservation.prescriptionUrl1?.isNotEmpty == true)
        reservation.prescriptionUrl1!,

      if (reservation.prescriptionUrl2?.isNotEmpty == true)
        reservation.prescriptionUrl2!,
    ];

    final properties = medicalRecord?.properties ?? [];

    final hasNotes = medicalRecord?.notes?.trim().isNotEmpty == true;

    final hasRevisit = medicalRecord?.revisitDate?.trim().isNotEmpty == true;

    final hasPhotos = medicalRecord?.photos?.isNotEmpty == true;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),

      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.dividerAndLines),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),

        child: ExpansionTile(
          initiallyExpanded: isInitiallyExpanded,

          tilePadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),

          childrenPadding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),

          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),

          iconColor: AppColors.primary,

          collapsedIconColor: AppColors.textSecondaryParagraph,

          // =====================================================
          // HEADER
          // =====================================================
          title: Row(
            children: [
              /// ICON
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: AppColors.primary.withValues(alpha: 0.10),
                ),
                child: Icon(
                  Icons.monitor_heart_rounded,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
              ),

              SizedBox(width: 12.w),

              /// INFO
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicalRecord?.categoryName ?? "كشف طبي",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.typography.smMedium.copyWith(
                        color: AppColors.text_primary_paragraph,
                      ),
                    ),
                    if (medicalRecord?.createAt != null)
                      Text(
                        DatesUtilis.formatDateTime(medicalRecord?.createAt),
                        style: context.typography.xsRegular.copyWith(
                          color: AppColors.grayMedium,
                        ),
                      ),
                  ],
                ),
              ),

              /// STATUS
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.successForeground.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  "مكتمل",
                  style: context.typography.xsMedium.copyWith(
                    color: AppColors.successForeground,
                  ),
                ),
              ),
            ],
          ),

          // =====================================================
          // BODY
          // =====================================================
          children: [
            /// ===============================================
            /// QUICK INFO
            /// ===============================================

            /// ===============================================
            /// RESULTS
            /// ===============================================
            if (properties.isNotEmpty) ...[
              GridView.builder(
                shrinkWrap: true,

                physics: const NeverScrollableScrollPhysics(),

                itemCount: properties.length,

                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,

                  mainAxisSpacing: 10.h,
                  crossAxisSpacing: 10.w,

                  childAspectRatio: 2,
                ),

                itemBuilder: (_, index) {
                  final property = properties[index];

                  return Container(
                    padding: EdgeInsets.all(14.w),

                    decoration: BoxDecoration(
                      color: AppColors.background_neutral_100,

                      borderRadius: BorderRadius.circular(18.r),
                    ),

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,

                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          property.label ?? "",

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,

                          style: context.typography.mdMedium.copyWith(
                            color: AppColors.textSecondaryParagraph,
                          ),
                        ),

                        const SizedBox(height: 5),
                        Text(
                          "${property.value ?? "-"}",

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,

                          style: context.typography.lgBold.copyWith(
                            color: AppColors.background_black,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
            ],

            if (hasNotes || hasRevisit)
              Container(
                width: double.infinity,

                padding: EdgeInsets.all(16.w),

                decoration: BoxDecoration(
                  color: AppColors.background_neutral_100,

                  borderRadius: BorderRadius.circular(20.r),
                ),

                child: Column(
                  children: [
                    /// REVISIT
                    if (hasRevisit)
                      _infoRow(
                        context,
                        icon: Icons.event_repeat_rounded,
                        title: "إعادة الكشف",
                        value: medicalRecord?.revisitDate ?? "-",
                      ),

                    /// NOTES
                    if (hasNotes) ...[
                      if (hasRevisit) SizedBox(height: 14.h),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Icon(
                            Icons.notes_rounded,
                            size: 18.sp,
                            color: AppColors.primary,
                          ),

                          SizedBox(width: 10.w),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Text(
                                  "ملاحظات",

                                  style: context.typography.mdBold.copyWith(
                                    color: AppColors.text_primary_paragraph,
                                  ),
                                ),

                                SizedBox(height: 5.h),

                                Text(
                                  medicalRecord?.notes ?? "-",

                                  style: context.typography.smMedium.copyWith(
                                    color: AppColors.textSecondaryParagraph,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

            /// ===============================================
            /// PHOTOS
            /// ===============================================
            if (hasPhotos) ...[
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.photo_library_rounded,
                      size: 20.sp,
                      color: AppColors.primary,
                    ),

                    SizedBox(width: 8.w),

                    Text(
                      "صور الكشف",

                      style: context.typography.mdBold.copyWith(
                        color: AppColors.text_primary_paragraph,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 8.h),

              SizedBox(
                height: 92.h,

                child: ListView.separated(
                  scrollDirection: Axis.horizontal,

                  itemCount: medicalRecord?.photos?.length ?? 0,

                  separatorBuilder: (_, __) => SizedBox(width: 10.w),

                  itemBuilder: (_, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(18.r),

                      child: Image.network(
                        medicalRecord!.photos![index],

                        width: 92.w,
                        height: 92.h,

                        fit: BoxFit.cover,

                        errorBuilder: (_, error, stackTrace) {
                          return Container(
                            width: 92.w,
                            height: 92.h,

                            color: AppColors.background_neutral_100,

                            child: Icon(
                              Icons.broken_image_rounded,
                              color: AppColors.grayMedium,
                            ),
                          );
                        },

                        loadingBuilder: (_, child, loadingProgress) {
                          if (loadingProgress == null) return child;

                          return Container(
                            width: 92.w,
                            height: 92.h,

                            alignment: Alignment.center,

                            color: AppColors.background_neutral_100,

                            child: const CircularProgressIndicator(),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: AppColors.primary),

        SizedBox(width: 10.w),

        Text(
          "$title : ",

          style: context.typography.mdBold.copyWith(
            color: AppColors.text_primary_paragraph,
          ),
        ),

        Expanded(
          child: Text(
            value,

            style: context.typography.smMedium.copyWith(
              color: AppColors.textSecondaryParagraph,
            ),
          ),
        ),
      ],
    );
  }
}
