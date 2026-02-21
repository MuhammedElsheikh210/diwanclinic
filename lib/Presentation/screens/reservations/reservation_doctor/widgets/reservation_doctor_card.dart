import 'package:diwanclinic/Data/Core/whatsapp_manager.dart';
import 'package:diwanclinic/Presentation/screens/patients/profile_history_all_reservations/patient_profile_view.dart';
import '../../../../../index/index_main.dart';

class ReservationDoctorCard extends StatelessWidget {
  final ReservationModel reservation;
  final ReservationDoctorViewModel controller;
  final int index;

  const ReservationDoctorCard({
    Key? key,
    required this.reservation,
    required this.controller,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = ReservationStatusExt.fromValue(reservation.status ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderNeutralPrimary, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context, status),
          const SizedBox(height: 6),
          _patientInfo(context),
          if (_hasPrescription) _prescriptionSection(context),
          const SizedBox(height: 4),
          _reservationInfo(context),
          const Divider(height: 20, thickness: 1, color: AppColors.grayLight),
          _actions(context, status),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // 🔹 Header: Queue Number + Status Badge
  // ---------------------------------------------------------
  Widget _header(BuildContext context, ReservationStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background_neutral_100,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border(
          bottom: BorderSide(color: AppColors.borderNeutralPrimary, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                "دورك رقم",
                style: context.typography.smRegular.copyWith(
                  color: AppColors.textSecondaryParagraph,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                "#${reservation.order_num ?? '-'}",
                style: context.typography.lgBold.copyWith(
                  color: AppColors.textDisplay,
                ),
              ),
            ],
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

  // ---------------------------------------------------------
  // 🔹 Patient Info
  // ---------------------------------------------------------
  Widget _patientInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                const Svgicon(
                  icon: IconsConstants.avatar,
                  width: 26,
                  height: 26,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "اسم الحالة",
                      style: context.typography.smRegular.copyWith(
                        color: AppColors.textSecondaryParagraph,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      reservation.patientName ?? "بدون اسم",
                      style: context.typography.mdBold.copyWith(
                        color: AppColors.textDisplay,
                      ),
                    ),

                    // --------------------------------------------------
                    // 🔥 NEW — Show File Number (if clinic has file_number)
                    // --------------------------------------------------
                    // if (controller.selectedClinic?.file_number != 0) ...[
                    //   const SizedBox(height: 4),
                    //   Text(
                    //     "رقم الملف: ${controller.selectedClinic!.file_number}",
                    //     style: context.typography.smMedium.copyWith(
                    //       color: AppColors.primary,
                    //     ),
                    //   ),
                    // ],
                  ],
                ),
              ],
            ),
          ),

          if (reservation.transfer_image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: reservation.transfer_image!,
                width: 80,
                height: 55,
                fit: BoxFit.cover,
              ),
            ),
        ],
      ),
    );
  }

  bool get _hasPrescription =>
      (reservation.prescriptionUrl1?.isNotEmpty == true) ||
      (reservation.prescriptionUrl2?.isNotEmpty == true);

  // ---------------------------------------------------------
  // 🔹 Prescription Section
  // ---------------------------------------------------------
  Widget _prescriptionSection(BuildContext context) {
    final images = <String>[
      if (reservation.prescriptionUrl1?.isNotEmpty == true)
        reservation.prescriptionUrl1!,
      if (reservation.prescriptionUrl2?.isNotEmpty == true)
        reservation.prescriptionUrl2!,
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background_neutral_100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderNeutralPrimary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "الروشتة",
            style: context.typography.mdBold.copyWith(
              color: AppColors.textDisplay,
            ),
          ),
          const SizedBox(height: 8),

          SizedBox(
            height: 75,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: images[i],
                      fit: BoxFit.cover,
                      width: 110,
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

  // ---------------------------------------------------------
  // 🔹 Reservation Type
  // ---------------------------------------------------------
  Widget _reservationInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: ReservationListTileWidget(
              icon: IconsConstants.calendar,
              title: "نوع الحجز",
              body: reservation.reservationType ?? "",
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // 🔹 Action Buttons
  // ---------------------------------------------------------
  Widget _actions(BuildContext context, ReservationStatus status) {
    List<Widget> buttons = [];

    // View Details
    buttons.add(
      Expanded(
        child: PrimaryTextButton(
          onTap: () {
            Get.to(
              () => PatientAllHistoryView(
                patient_key: reservation.patientKey ?? "",
              ),
              binding: Binding(),
            );
          },
          appButtonSize: AppButtonSize.large,
          customBackgroundColor: AppColors.white,
          customBorder: const BorderSide(
            color: AppColors.borderNeutralPrimary,
            width: 1,
          ),
          label: AppText(
            text: "عرض التفاصيل",
            textStyle: context.typography.mdBold.copyWith(
              color: AppColors.textDisplay,
            ),
          ),
        ),
      ),
    );

    // Status Buttons
    if (status == ReservationStatus.pending) {
      buttons.add(const SizedBox(width: 8));

      buttons.add(
        Expanded(
          child: PrimaryTextButton(
            onTap: () => _updateStatus(ReservationStatus.approved),
            appButtonSize: AppButtonSize.large,
            customBackgroundColor: AppColors.successBackground,
            label: AppText(
              text: "موافقة",
              textStyle: context.typography.mdMedium.copyWith(
                color: AppColors.successForeground,
              ),
            ),
          ),
        ),
      );

      buttons.add(const SizedBox(width: 8));

      buttons.add(
        Expanded(
          child: PrimaryTextButton(
            onTap: () => _updateStatus(ReservationStatus.cancelledByAssistant),
            appButtonSize: AppButtonSize.large,
            customBackgroundColor: AppColors.errorForeground,
            label: AppText(
              text: "إلغاء",
              textStyle: context.typography.mdMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    if (status == ReservationStatus.inProgress) {
      buttons.add(const SizedBox(width: 8));

      buttons.add(
        Expanded(
          child: PrimaryTextButton(
            onTap: () => _updateStatus(ReservationStatus.completed),
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
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(children: buttons),
    );
  }

  // ---------------------------------------------------------
  // 🔔 Send WhatsApp Message on Completed
  // ---------------------------------------------------------
  Future<void> _updateStatus(ReservationStatus newStatus) async {
    if (newStatus == ReservationStatus.completed) {
      try {
        final phone = reservation.patientPhone ?? "";
        if (phone.isNotEmpty) {
             final formatted = WhatsAppManager.formatNumber(phone);
        //  const formatted = "01551061194";

          final patient = reservation.patientName ?? "المريض";
          final doctor = LocalUser().getUserData().name ?? "العيادة";
          const android = Strings.url_android;
          const ios = Strings.url_ios;

          final message =
              """
من عيادة د. $doctor 👨‍⚕️

الكشف خلص يا $patient 🌿  
تقدر تطلب العلاج لحد بيتك مع خصم 5٪ - 10٪

سجل دخول على تطبيق لينك باستخدام رقمك:  
$phone

📱 أندرويد: $android  
🍎 آيفون: $ios
""";

          if (controller.selectedClinic?.sendWhatsapp == 1) {
            await WhatsAppManager.sendMessage(to: formatted, body: message);
          }
        }
      } catch (_) {}
    }

    reservation.status = newStatus.value;
    controller.updateReservation(reservation);
    Loader.showSuccess("تم تحديث الحالة إلى ${newStatus.label}");
  }
}
