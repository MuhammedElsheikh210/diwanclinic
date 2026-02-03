import '../../../../../../index/index_main.dart';

class ReservationPatientCard extends StatelessWidget {
  final ReservationModel reservation;
  final ReservationPatientViewModel controller;
  final int index;
  final bool? from_home;

  const ReservationPatientCard({
    super.key,
    required this.reservation,
    required this.controller,
    required this.index,
    this.from_home,
  });

  @override
  Widget build(BuildContext context) {
    // 🔍 Convert reservation status string → ReservationStatus enum
    final status = ReservationStatusExt.fromValue(reservation.status ?? "");

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: ColorMappingImpl().borderNeutralPrimary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🟦 HEADER
          // Shows reservation number + status badge only
          HeaderSection(
            reservation: reservation,
            status: status,
            controller: controller,
          ),

          if (reservation.status == ReservationStatus.pending.value) ...[
            SizedBox(height: 8.h),
            _waitingAssistantHint(context),
          ],

          const SizedBox(height: 15),
          // 👨‍⚕️ DOCTOR INFO
          // Assigned doctor name
          DoctorInfoSection(reservation: reservation),

          // 💰 PAYMENT INFO
          // SECTION: Reservation Details
          ReservationDetailsSection(reservation: reservation),

          OrderMedicineWidget(
            isOrdered: reservation.isOrdered ?? false,
            onTap: () {
              Get.to(
                () => OrderMedicineScreen(
                  reservation: reservation,
                  onConfirmed: (ReservationModel p1) {
                    controller.updateReservation(p1);
                    Get.offAll(
                      () => const MainPage(initialIndex: 2),
                      binding: Binding(),
                    );
                  },
                ),
                binding: Binding(),
              );
            },
          ),

          // 🔘 ACTION BUTTONS
          // Cancel, Rate Doctor, Request Prescription
          ButtonsSection(
            reservation: reservation,
            controller: controller,
            status: status,
            index: index,
            show_details: true,
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 🟣 make order
  // ---------------------------------------------------------------------------
  void _makeOrder() {
    if ((reservation.prescriptionUrl1 == null ||
            reservation.prescriptionUrl1!.isEmpty) &&
        (reservation.prescriptionUrl2 == null ||
            reservation.prescriptionUrl2!.isEmpty)) {
      _showUploadRequiredSheet(Get.context!);
      return;
    }

    controller.openOrderConfirmationSheet(
      context: Get.context!,
      reservation: reservation,
    );
  }

  // ---------------------------------------------------------------------------
  // 🔵 show upload required sheet
  // ---------------------------------------------------------------------------
  void _showUploadRequiredSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) =>
          UploadRequiredSheet(reservation: reservation, controller: controller),
    );
  }

  Widget _waitingAssistantHint(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 16, color: AppColors.tag_icon_warning),
          SizedBox(width: 6.w),
          Expanded(
            child: AppText(
              text:
                  "بانتظار موافقة المساعدة على الحجز، سيتم إشعارك فور التأكيد",
              textStyle: context.typography.xsMedium.copyWith(
                color: AppColors.textSecondaryParagraph,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ⭐ show feedback sheet
  // ---------------------------------------------------------------------------
  void _showFeedbackBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) =>
          FeedbackSheet(reservation: reservation, controller: controller),
    );
  }
}
