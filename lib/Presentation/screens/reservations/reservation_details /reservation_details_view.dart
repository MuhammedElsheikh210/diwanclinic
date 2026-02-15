
import '../../../../../../index/index_main.dart';

class ReservationAssistantDetailsView extends StatelessWidget {
  final ReservationModel reservation;
  final ReservationViewModel controller;
  final int index;

  const ReservationAssistantDetailsView({
    Key? key,
    required this.reservation,
    required this.controller,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = ReservationStatusNewExt.fromValue(reservation.status ?? "");
    final ahead = controller.queueManager.aheadInQueue(
      reservations: controller.listReservations,
      target: reservation,
    );
    final transferImage = reservation.transfer_image;
    final bool isCompletedOrCancelled =
        reservation.status == ReservationNewStatus.completed.value ||
        reservation.status == ReservationNewStatus.cancelledByAssistant.value;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text("تفاصيل الحجز", style: context.typography.mdBold),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),

      body: Container(
        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 30),
        decoration: BoxDecoration(
          color: reservation.reservationType == "كشف مستعجل"
              ? AppColors.errorForeground.withValues(alpha: 0.3)
              : AppColors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: ColorMappingImpl().borderNeutralPrimary),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.background_neutral_100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// رقم الحجز
                  isCompletedOrCancelled ||
                          reservation.reservationType == "كشف مستعجل"
                      ? const SizedBox()
                      : Column(
                          children: [
                            /// 🔹 Header: رقم الحجز + حالة + Edit
                            ///
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child:
                                  ahead >= 0 &&
                                      (reservation.status !=
                                              ReservationStatus
                                                  .completed
                                                  .value &&
                                          reservation.status !=
                                              ReservationStatus
                                                  .inProgress
                                                  .value)
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: ahead == 0
                                          ? Text(
                                              "دورك دلوقتي",
                                              style: context.typography.mdMedium
                                                  .copyWith(
                                                    color: AppColors
                                                        .background_black,
                                                  ),
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                AppText(
                                                  text: " : قدامك",
                                                  textStyle: context
                                                      .typography
                                                      .mdMedium
                                                      .copyWith(
                                                        color: ColorMappingImpl()
                                                            .textSecondaryParagraph,
                                                      ),
                                                ),
                                                const SizedBox(width: 5),
                                                AppText(
                                                  text: "$ahead",
                                                  textStyle: context
                                                      .typography
                                                      .lgBold
                                                      .copyWith(
                                                        color:
                                                            ColorMappingImpl()
                                                                .textDisplay,
                                                      ),
                                                ),
                                              ],
                                            ),
                                    )
                                  : const SizedBox(),
                            ),
                            Row(
                              children: [
                                AppText(
                                  text: " :رقم الحجز",
                                  textStyle: context.typography.mdMedium
                                      .copyWith(
                                        color: ColorMappingImpl()
                                            .textSecondaryParagraph,
                                      ),
                                ),
                                const SizedBox(width: 5),
                                AppText(
                                  text: "${reservation.order_num ?? '-'}",
                                  textStyle: context.typography.lgBold.copyWith(
                                    color: ColorMappingImpl().textDisplay,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                  /// الحالة + زر تعديل
                  Row(
                    children: [
                      StatusBadge(
                        status: reservation.status ?? "",
                        label: status.label,
                        dateTimeStamp: 0,
                        color: status.color,
                      ),
                      const SizedBox(width: 8),
                      reservation.status == "completed"
                          ? const SizedBox()
                          : InkWell(
                              onTap: () async {
                                final trueTotal = await controller
                                    .getTotalTodayReservations();

                                // 🟢 فتح شاشة تعديل الحجز
                                Get.delete<CreateReservationViewModel>();
                                int total =
                                    controller.listReservations?.length ?? 0;
                                Get.to(
                                  () => CreateReservationView(
                                    list_reservations:
                                        controller.listReservations ?? [],

                                    dailly_date:
                                        controller.appointmentDate ?? "",

                                    clinic_key: controller.selectedClinic?.key,
                                    shift_key: controller.selectedShift?.key,
                                    selected_clinic:
                                        controller.selectedClinic ??
                                        ClinicModel(),
                                    reservation: reservation,
                                    total_reservations: trueTotal,
                                  ),
                                );
                              },
                              child: Svgicon(
                                icon: IconsConstants.edit_btn,
                                height: 30.h,
                                width: 30.w,
                                color: AppColors.primary,
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),

            /// 🔹 Patient Name + Phone
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 10,
                    ),
                    child: AppLisTile(
                      leading: const Svgicon(icon: IconsConstants.avatar),
                      title: AppText(
                        text: "الحالة",
                        textStyle: context.typography.mdRegular.copyWith(
                          color: ColorMappingImpl().textSecondaryParagraph,
                        ),
                      ),
                      subtitle: AppText(
                        text: reservation.patientName ?? "بدون اسم",
                        textStyle: context.typography.lgBold.copyWith(
                          color: ColorMappingImpl().textDisplay,
                        ),
                      ),
                    ),
                  ),
                ),

                if (transferImage != null && transferImage.isNotEmpty)
                  InkWell(
                    onTap: () {
                      // 🖼️ Open full screen preview
                      Get.to(
                        () => FullScreenImageView(imageUrl: transferImage),
                        transition: Transition.fadeIn,
                        duration: const Duration(milliseconds: 250),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.0, right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: transferImage,
                          fit: BoxFit.cover,
                          height: 55.w,
                          width: 85.w,
                          placeholder: (context, url) => Container(
                            height: 55.w,
                            width: 85.w,
                            color: AppColors.background_neutral_100,
                            child: const Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 55.w,
                            width: 85.w,
                            color: AppColors.background_neutral_100,
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(),
              ],
            ),

            /// 🔹 Type + Amounts
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: ReservationListTileWidget(
                      icon: IconsConstants.money,
                      title: "المدفوع",
                      body: reservation.paidAmount ?? "0",
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 5,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
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

                          // ✅ Collect available prescription URLs
                          Builder(
                            builder: (_) {
                              final images = <String>[
                                if (reservation.prescriptionUrl1?.isNotEmpty ==
                                    true)
                                  reservation.prescriptionUrl1!,
                                if (reservation.prescriptionUrl2?.isNotEmpty ==
                                    true)
                                  reservation.prescriptionUrl2!,
                              ];
                              print("images is ${images}");

                              // ✅ If no images → show upload button
                              // ✅ If no images
                              if (images.isEmpty) {
                                final isCompleted =
                                    reservation.status ==
                                    ReservationNewStatus.completed.value;

                                print("isCompleted is ${isCompleted}");

                                if (isCompleted) {
                                  // 🔹 Allow upload after finish
                                  return GestureDetector(
                                    onTap: () {
                                      print("doneee");
                                      controller.prescriptionService
                                          .openBottomSheet(
                                            context: context,
                                            reservation: reservation,
                                            onUpdated: () {
                                              controller.getReservations();
                                              controller.update();
                                            },
                                          );
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(top: 5.h),
                                      height: 45.h,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: AppColors.background_neutral_100,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.upload_file,
                                            color: AppColors.primary,
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            'تحميل الروشتة',
                                            style: context.typography.mdMedium
                                                .copyWith(
                                                  color: AppColors.primary,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                } else {
                                  // 🔹 Indication only — not clickable
                                  return Container(
                                    margin: EdgeInsets.only(top: 5.h),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 10.h,
                                      horizontal: 10.w,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.background_neutral_100,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.borderNeutralPrimary
                                            .withOpacity(0.5),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.lock_clock,
                                          color:
                                              AppColors.textSecondaryParagraph,
                                        ),
                                        SizedBox(width: 6.w),
                                        Expanded(
                                          child: Text(
                                            ' ستقوم بتصوير الروشتة بعد انتهاء الكشف',
                                            style: context.typography.smRegular
                                                .copyWith(
                                                  color: AppColors
                                                      .textSecondaryParagraph,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              }

                              // ✅ If images exist → show them in a horizontal list
                              return SizedBox(
                                height: 80.h,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: images.length,
                                  separatorBuilder: (_, __) =>
                                      SizedBox(width: 8.w),
                                  itemBuilder: (_, i) => GestureDetector(
                                    onTap: () {
                                      controller.prescriptionService
                                          .openBottomSheet(
                                            context: context,
                                            reservation: reservation,
                                            onUpdated: () {
                                              controller.getReservations();
                                              controller.update();
                                            },
                                          );

                                      // Get.to(
                                      //   () => FullScreenImageView(
                                      //     imageUrl: images[i],
                                      //   ),
                                      // );
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
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// 🔹 Date of Reservation
            Row(
              children: [
                Expanded(
                  child: ReservationListTileWidget(
                    icon: IconsConstants.reserve_type,
                    title: "نوع الحجز",
                    body: reservation.reservationType ?? "",
                  ),
                ),
                Expanded(
                  child: ReservationListTileWidget(
                    icon: IconsConstants.calendar,
                    title: "تاريخ الحجز",
                    body: DatesUtilis.convertTimestamp(
                      reservation.createAt ?? 0,
                    ),
                  ),
                ),
              ],
            ),

            /// 🔹 Action Buttons (Dynamic by Status)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: _buildButtons(context, status),
            ),
          ],
        ),
      ),
    );
  }

  /// 🟢 Build buttons depending on status
  Widget _buildButtons(BuildContext context, ReservationNewStatus status) {
    List<Widget> buttons = [];

    // // Always show details
    if (reservation.isOrdered != true &&
        ReservationNewStatus.completed == status) {
      buttons.add(
        Expanded(
          child: PrimaryTextButton(
            onTap: () => _makeOrder(),
            appButtonSize: AppButtonSize.large,
            customBackgroundColor: ColorMappingImpl().white,
            customBorder: BorderSide(
              color: ColorMappingImpl().borderNeutralPrimary,
            ),
            label: AppText(
              text: "طلب الروشتة",
              textStyle: context.typography.mdMedium.copyWith(
                color: ColorMappingImpl().textDefault,
              ),
            ),
          ),
        ),
      );
    }

    buttons.add(SizedBox(width: 5.w));

    // Status based logic
    switch (status) {
      case ReservationNewStatus.pending:
        final reservations =
            controller.listReservations
                ?.where(
                  (r) =>
                      r != null &&
                      r.order_num != null &&
                      r.order_num.toString().isNotEmpty &&
                      (r.status == ReservationStatus.approved.value ||
                          r.status == ReservationStatus.inProgress.value),
                )
                .toList() ??
            [];

        // لو مفيش ولا حجز
        int lastOrderNum = 0;

        // if (reservations.isNotEmpty) {
        //   lastOrderNum = reservations
        //       .map((r) => int.tryParse(r!.order_num.toString()) ?? 0)
        //       .reduce((a, b) => a > b ? a : b);
        // }

        // الجديد = آخر رقم + 1
        //   reservation.order_num = lastOrderNum + 1;

        // Show Approve + Cancel
        buttons.addAll([
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              child: PrimaryTextButton(
                onTap: () => _updateStatus(ReservationStatus.approved),
                appButtonSize: AppButtonSize.large,
                customBackgroundColor: AppColors.successBackground, // green
                label: AppText(
                  text: "موافقة",
                  textStyle: context.typography.mdMedium.copyWith(
                    color: AppColors.successForeground,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 5.w),
          Expanded(
            child: PrimaryTextButton(
              onTap: () =>
                  _updateStatus(ReservationStatus.cancelledByAssistant),
              appButtonSize: AppButtonSize.large,
              customBackgroundColor: AppColors.errorForeground, // red
              label: AppText(
                text: "إلغاء",
                textStyle: context.typography.mdMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ]);
        break;

      case ReservationNewStatus.approved:
        // Show Go Doctor + Cancel
        buttons.addAll([
          Expanded(
            child: PrimaryTextButton(
              onTap: () => _updateStatus(ReservationStatus.inProgress),
              appButtonSize: AppButtonSize.large,
              customBackgroundColor: AppColors.primary, // blue
              label: AppText(
                text: "إبدأ الكشف",
                textStyle: context.typography.mdMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 5.w),

          Expanded(
            child: PrimaryTextButton(
              onTap: () =>
                  _updateStatus(ReservationStatus.cancelledByAssistant),
              appButtonSize: AppButtonSize.large,
              customBackgroundColor: AppColors.errorForeground, // red
              label: AppText(
                text: "إلغاء",
                textStyle: context.typography.mdMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ]);
        break;

      case ReservationNewStatus.inProgress:
        // Show Complete + Cancel
        buttons.addAll([
          Expanded(
            child: PrimaryTextButton(
              onTap: () => _updateStatus(ReservationStatus.completed),
              appButtonSize: AppButtonSize.large,
              customBackgroundColor: AppColors.background_black,
              label: AppText(
                text: "تم الكشف",
                textStyle: context.typography.mdBold.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ]);
        break;

      default:
        // Completed / Cancelled → no actions
        break;
    }

    return Row(children: buttons);
  }

  void _makeOrder() {
    if ((reservation.prescriptionUrl1 == null ||
            reservation.prescriptionUrl1!.isEmpty) &&
        (reservation.prescriptionUrl2 == null ||
            reservation.prescriptionUrl2!.isEmpty)) {
      _showUploadRequiredSheet(Get.context!, reservation);
      return;
    }

    openOrderConfirmationSheet(Get.context!, controller, reservation);
  }

  void _showUploadRequiredSheet(
    BuildContext context,
    ReservationModel reservation,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Small drag handle
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  "تنبيه هام",
                  style: context.typography.xlBold.copyWith(
                    color: AppColors.textDisplay,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  "يجب عليك أولاً رفع صورة الروشتة بعد انتهاء الكشف.\n"
                  "ستحصل على خصم يصل إلى 10%، وسيتم توصيل العلاج إلى باب منزلك 🚚💊",
                  textAlign: TextAlign.center,
                  style: context.typography.mdRegular.copyWith(
                    color: AppColors.textSecondaryParagraph,
                  ),
                ),

                const SizedBox(height: 25),

                // رفع الروشتة
                SizedBox(
                  width: double.infinity,
                  child: PrimaryTextButton(
                    appButtonSize: AppButtonSize.xxLarge,
                    customBackgroundColor: AppColors.primary,
                    label: AppText(
                      text: "رفع الروشتة",
                      textStyle: context.typography.mdBold.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      controller.prescriptionService.openBottomSheet(
                        context: context,
                        reservation: reservation,
                        onUpdated: () {
                          controller.getReservations();
                          controller.update();
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // إغلاق
                SizedBox(
                  width: double.infinity,
                  child: PrimaryTextButton(
                    appButtonSize: AppButtonSize.large,
                    customBackgroundColor: AppColors.background_neutral_100,
                    label: AppText(
                      text: "إغلاق",
                      textStyle: context.typography.mdMedium.copyWith(
                        color: AppColors.textDefault,
                      ),
                    ),
                    onTap: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateStatus(ReservationStatus newStatus) async {
    Loader.show();

    // =================================================
    // 🔄 1) UPDATE STATUS (ONCE)
    // =================================================
    reservation.status = newStatus.value;
    controller.fromUpdate = true;

    await controller.actionManager.updateReservation(
      reservation,
      isSyncing: false,
    );
    await controller.getReservations();
    controller.update();

    // =================================================
    // 🔔 2) SIDE EFFECTS BY STATUS
    // =================================================
    switch (newStatus) {
      // ---------------------------
      // APPROVED
      // ---------------------------
      case ReservationStatus.approved:
        await NotificationHandler().sendStatusNotification(
          newStatus: ReservationStatus.approved,
          reservation: reservation,
          toToken: reservation.fcmToken_patient ?? "",
        );

        await WhatsAppStatusMessageService.sendStatusWhatsAppMessage(
          reservation: reservation,
          clinic: controller.selectedClinic,
          newStatus: newStatus,
        );
        break;

      // ---------------------------
      // COMPLETED
      // ---------------------------
      case ReservationStatus.completed:
        await NotificationHandler().sendStatusNotification(
          newStatus: ReservationStatus.completed,
          reservation: reservation,
          toToken: reservation.fcmToken_patient ?? "",
        );

        await WhatsAppStatusMessageService.sendStatusWhatsAppMessage(
          reservation: reservation,
          clinic: controller.selectedClinic,
          newStatus: newStatus,
        );

        await controller.queueManager.notifyApprovedQueueUpdate(
          allReservations: controller.listReservations
              ?.whereType<ReservationModel>()
              .toList() ??
              [],
        );


        break;

      // ---------------------------
      // CANCELLED (ALL TYPES)
      // ---------------------------
      case ReservationStatus.cancelledByAssistant:
      case ReservationStatus.cancelledByDoctor:
      case ReservationStatus.cancelledByUser:
        await NotificationHandler().sendStatusNotification(
          newStatus: newStatus,
          reservation: reservation,
          toToken: reservation.fcmToken_patient ?? "",
        );
        break;

      // ---------------------------
      // DEFAULT
      // ---------------------------
      default:
        break;
    }

    Loader.showSuccess("تم تحديث الحالة إلى ${newStatus.label}");
  }
}
