import 'package:diwanclinic/Data/Core/whatsapp_manager.dart';
import 'package:diwanclinic/Presentation/screens/patients/profile_history_all_reservations/patient_profile_view.dart';

import '../../../../../index/index_main.dart';

class ReservationDoctorCard extends StatelessWidget {
  final ReservationModel reservation;
  final ReservationDoctorViewModel controller;
  final int index;

  const ReservationDoctorCard({
    super.key,
    required this.reservation,
    required this.controller,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final status = ReservationStatusExt.fromValue(reservation.status ?? '');

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(
          color: AppColors.borderNeutralPrimary.withOpacity(.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderSection(reservation: reservation, status: status),

          Padding(
            padding: EdgeInsets.all(18.w),
            child: Column(
              children: [
                _PatientSection(reservation: reservation),

                if (_hasPrescription) ...[
                  SizedBox(height: 18.h),

                  _PrescriptionSection(reservation: reservation),
                ],

                SizedBox(height: 18.h),

                _ReservationInfoSection(reservation: reservation),

                SizedBox(height: 18.h),

                Divider(
                  height: 1,
                  color: AppColors.borderNeutralPrimary.withOpacity(.6),
                ),

                SizedBox(height: 18.h),

                _ActionsSection(
                  reservation: reservation,
                  status: status,
                  controller: controller,
                  onUpdateStatus: _updateStatus,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool get _hasPrescription =>
      (reservation.prescriptionUrl1?.isNotEmpty == true) ||
      (reservation.prescriptionUrl2?.isNotEmpty == true);

  Future<void> _updateStatus(ReservationStatus newStatus) async {
    if (newStatus == ReservationStatus.completed) {
      reservation.status = newStatus.value;

      controller.updateReservation(reservation);

      Loader.showSuccess("تم تحديث الحالة إلى ${newStatus.label}");

      await WhatsAppStatusMessageService.sendStatusWhatsAppMessage(
        reservation: reservation,
        clinic: controller.selectedClinic,
        newStatus: newStatus,
      );
    }
  }
}

class _HeaderSection extends StatelessWidget {
  final ReservationModel reservation;
  final ReservationStatus status;

  const _HeaderSection({required this.reservation, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),

      decoration: BoxDecoration(
        color: AppColors.background_neutral_100,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28.r),
          topRight: Radius.circular(28.r),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 54.w,
            height: 54.w,

            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(.08),
              borderRadius: BorderRadius.circular(18.r),
            ),

            child: Center(
              child: Text(
                "#${reservation.orderNum ?? "-"}",
                style: context.typography.lgBold.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          SizedBox(width: 14.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "رقم الدور",
                  style: context.typography.smMedium.copyWith(
                    color: AppColors.textSecondaryParagraph,
                  ),
                ),

                SizedBox(height: 4.h),

                Text(
                  status.label,
                  style: context.typography.lgBold.copyWith(
                    color: AppColors.textDisplay,
                  ),
                ),
              ],
            ),
          ),

          StatusBadge(
            status: reservation.status ?? "",
            label: status.label,
            dateTimeStamp: 0,
            color: status.color,
          ),
        ],
      ),
    );
  }
}

class _PatientSection extends StatelessWidget {
  final ReservationModel reservation;

  const _PatientSection({required this.reservation});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 62.w,
          height: 62.w,

          decoration: BoxDecoration(
            color: AppColors.background_neutral_100,
            borderRadius: BorderRadius.circular(20.r),
          ),

          child: const Center(
            child: Svgicon(icon: IconsConstants.avatar, width: 28, height: 28),
          ),
        ),

        SizedBox(width: 14.w),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "اسم الحالة",
                style: context.typography.smRegular.copyWith(
                  color: AppColors.textSecondaryParagraph,
                ),
              ),

              SizedBox(height: 5.h),

              Text(
                reservation.patientName ?? "بدون اسم",
                style: context.typography.lgBold.copyWith(
                  color: AppColors.textDisplay,
                ),
              ),

              SizedBox(height: 10.h),

              // Container(
              //   padding: EdgeInsets.symmetric(
              //     horizontal: 10.w,
              //     vertical: 6.h,
              //   ),
              //
              //   decoration: BoxDecoration(
              //     color: AppColors.background_neutral_100,
              //     borderRadius: BorderRadius.circular(100.r),
              //   ),
              //
              //   child: Text(
              //     reservation.reservationType ?? "",
              //     style: context.typography.smMedium.copyWith(
              //       color: AppColors.textDisplay,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),

        if (reservation.transferImage != null)
          Hero(
            tag: reservation.transferImage!,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18.r),
              child: CachedNetworkImage(
                imageUrl: reservation.transferImage!,
                width: 92.w,
                height: 74.h,
                fit: BoxFit.cover,
              ),
            ),
          ),
      ],
    );
  }
}

class _PrescriptionSection extends StatelessWidget {
  final ReservationModel reservation;

  const _PrescriptionSection({required this.reservation});

  @override
  Widget build(BuildContext context) {
    final images = <String>[
      if (reservation.prescriptionUrl1?.isNotEmpty == true)
        reservation.prescriptionUrl1!,
      if (reservation.prescriptionUrl2?.isNotEmpty == true)
        reservation.prescriptionUrl2!,
    ];

    return Container(
      padding: EdgeInsets.all(14.w),

      decoration: BoxDecoration(
        color: AppColors.background_neutral_100,
        borderRadius: BorderRadius.circular(22.r),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long_rounded,
                color: AppColors.primary,
                size: 20.sp,
              ),

              SizedBox(width: 8.w),

              Text(
                "الروشتة الطبية",
                style: context.typography.mdBold.copyWith(
                  color: AppColors.textDisplay,
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          SizedBox(
            height: 84.h,

            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => SizedBox(width: 10.w),

              itemBuilder: (_, i) {
                return GestureDetector(
                  onTap: () {
                    Get.to(
                      () => FullScreenGalleryView(
                        imageUrls: images,
                        initialIndex: i,
                      ),
                    );
                  },

                  child: Hero(
                    tag: images[i],
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18.r),
                      child: CachedNetworkImage(
                        imageUrl: images[i],
                        width: 130.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReservationInfoSection extends StatelessWidget {
  final ReservationModel reservation;

  const _ReservationInfoSection({required this.reservation});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _InfoTile(
            title: "نوع الحجز",
            value: reservation.reservationType ?? "-",
            icon: Icons.calendar_month_rounded,
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.borderNeutralPrimary.withOpacity(.7),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,

            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(.08),
              borderRadius: BorderRadius.circular(14.r),
            ),

            child: Icon(icon, color: AppColors.primary, size: 20.sp),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.typography.smRegular.copyWith(
                    color: AppColors.textSecondaryParagraph,
                  ),
                ),

                SizedBox(height: 4.h),

                Text(
                  value,
                  style: context.typography.mdBold.copyWith(
                    color: AppColors.textDisplay,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionsSection extends StatelessWidget {
  final ReservationModel reservation;
  final ReservationStatus status;
  final ReservationDoctorViewModel controller;

  final Function(ReservationStatus) onUpdateStatus;

  const _ActionsSection({
    required this.reservation,
    required this.status,
    required this.controller,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PrimaryTextButton(
            onTap: () {
              Get.to(
                () => PatientAllHistoryView(
                  patientKey: reservation.patientUid ?? "",
                ),
                binding: Binding(),
              );
            },

            appButtonSize: AppButtonSize.large,

            customBackgroundColor: AppColors.white,

            customBorder: BorderSide(color: AppColors.borderNeutralPrimary),

            label: AppText(
              text: "عرض التفاصيل",

              textStyle: context.typography.mdBold.copyWith(
                color: AppColors.textDisplay,
              ),
            ),
          ),
        ),

        if (status == ReservationStatus.pending) ...[
          SizedBox(width: 10.w),

          Expanded(
            child: PrimaryTextButton(
              onTap: () {
                onUpdateStatus(ReservationStatus.approved);
              },

              appButtonSize: AppButtonSize.large,

              customBackgroundColor: AppColors.successBackground,

              label: AppText(
                text: "موافقة",

                textStyle: context.typography.mdBold.copyWith(
                  color: AppColors.successForeground,
                ),
              ),
            ),
          ),

          SizedBox(width: 10.w),

          Expanded(
            child: PrimaryTextButton(
              onTap: () {
                onUpdateStatus(ReservationStatus.cancelledByAssistant);
              },

              appButtonSize: AppButtonSize.large,

              customBackgroundColor: AppColors.errorForeground,

              label: AppText(
                text: "إلغاء",

                textStyle: context.typography.mdBold.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],

        if (status == ReservationStatus.inProgress) ...[
          SizedBox(width: 10.w),

          Expanded(
            child: PrimaryTextButton(
              onTap: () {
                onUpdateStatus(ReservationStatus.completed);
              },

              appButtonSize: AppButtonSize.large,

              customBackgroundColor: AppColors.primary,

              label: AppText(
                text: "تم الكشف",

                textStyle: context.typography.mdBold.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
