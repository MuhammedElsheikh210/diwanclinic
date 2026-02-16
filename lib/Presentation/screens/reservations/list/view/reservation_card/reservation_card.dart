
import 'package:diwanclinic/Presentation/screens/reservations/list/view/reservation_card/reservation_card_actions.dart';
import 'package:diwanclinic/Presentation/screens/reservations/list/view/reservation_card/reservation_card_body.dart';
import 'package:diwanclinic/Presentation/screens/reservations/list/view/reservation_card/reservation_card_header.dart';

import '../../../../../../index/index_main.dart';

// class ReservationCard extends StatelessWidget {
//   final ReservationModel reservation;
//   final ReservationViewModel controller;
//   final int index;
//
//   const ReservationCard({
//     Key? key,
//     required this.reservation,
//     required this.controller,
//     required this.index,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final status = ReservationStatusNewExt.fromValue(reservation.status ?? "");
//     final ahead = controller.queueManager.aheadInQueue(
//       reservations: controller.listReservations,
//       target: reservation,
//     );
//     final transferImage = reservation.transfer_image;
//     final bool isCompletedOrCancelled =
//         reservation.status == ReservationNewStatus.completed.value ||
//         reservation.status == ReservationNewStatus.cancelledByAssistant.value;
//
//     return Container(
//       decoration: BoxDecoration(
//         color: reservation.reservationType == "كشف مستعجل"
//             ? AppColors.errorForeground.withValues(alpha: 0.3)
//             : AppColors.white,
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(color: ColorMappingImpl().borderNeutralPrimary),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               color: ColorMappingImpl().background_neutral_100,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(15),
//                 topRight: Radius.circular(15),
//               ),
//               boxShadow: AppShadow.deals_cart_top_shadow,
//             ),
//             padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 /// رقم الحجز
//                 isCompletedOrCancelled ||
//                         reservation.reservationType == "كشف مستعجل"
//                     ? const SizedBox()
//                     : Column(
//                         children: [
//                           /// 🔹 Header: رقم الحجز + حالة + Edit
//                           ///
//                           Padding(
//                             padding: const EdgeInsets.only(left: 8.0),
//                             child:
//                                 ahead >= 0 &&
//                                     (reservation.status !=
//                                             ReservationStatus.completed.value &&
//                                         reservation.status !=
//                                             ReservationStatus.inProgress.value)
//                                 ? Container(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 8,
//                                       vertical: 6,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(20),
//                                     ),
//                                     child: ahead == 0
//                                         ? Text(
//                                             "دورك دلوقتي",
//                                             style: context.typography.mdMedium
//                                                 .copyWith(
//                                                   color: AppColors
//                                                       .background_black,
//                                                 ),
//                                           )
//                                         : Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.start,
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               AppText(
//                                                 text: " : قدامك",
//                                                 textStyle: context
//                                                     .typography
//                                                     .mdMedium
//                                                     .copyWith(
//                                                       color: ColorMappingImpl()
//                                                           .textSecondaryParagraph,
//                                                     ),
//                                               ),
//                                               const SizedBox(width: 5),
//                                               AppText(
//                                                 text: "$ahead",
//                                                 textStyle: context
//                                                     .typography
//                                                     .lgBold
//                                                     .copyWith(
//                                                       color: ColorMappingImpl()
//                                                           .textDisplay,
//                                                     ),
//                                               ),
//                                             ],
//                                           ),
//                                   )
//                                 : const SizedBox(),
//                           ),
//                           Row(
//                             children: [
//                               AppText(
//                                 text: " :رقم الحجز",
//                                 textStyle: context.typography.mdMedium.copyWith(
//                                   color:
//                                       ColorMappingImpl().textSecondaryParagraph,
//                                 ),
//                               ),
//                               const SizedBox(width: 5),
//                               AppText(
//                                 text: "${reservation.order_num ?? '-'}",
//                                 textStyle: context.typography.lgBold.copyWith(
//                                   color: ColorMappingImpl().textDisplay,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//
//                 /// الحالة + زر تعديل
//                 Row(
//                   children: [
//                     Column(
//                       children: [
//                         Text(
//                           reservation.reservationType ?? "",
//                           style: context.typography.lgBold.copyWith(
//                             color: AppColors.background_black,
//                           ),
//                         ),
//                         const SizedBox(height: 5),
//                         StatusBadge(
//                           status: reservation.status ?? "",
//                           label: status.label,
//                           dateTimeStamp: 0,
//                           color: status.color,
//                         ),
//                       ],
//                     ),
//                     const SizedBox(width: 8),
//                     reservation.status == "completed"
//                         ? const SizedBox()
//                         : InkWell(
//                             onTap: () async {
//                               final trueTotal = await controller
//                                   .getTotalTodayReservations();
//
//                               // 🟢 فتح شاشة تعديل الحجز
//                               Get.delete<CreateReservationViewModel>();
//                               int total =
//                                   controller.listReservations?.length ?? 0;
//                               Get.to(
//                                 () => CreateReservationView(
//                                   list_reservations:
//                                       controller.listReservations ?? [],
//
//                                   dailly_date: controller.appointmentDate ?? "",
//
//                                   clinic_key: controller.selectedClinic?.key,
//                                   shift_key: controller.selectedShift?.key,
//                                   selected_clinic:
//                                       controller.selectedClinic ??
//                                       ClinicModel(),
//                                   reservation: reservation,
//                                   total_reservations: trueTotal,
//                                 ),
//                               );
//                             },
//                             child: Svgicon(
//                               icon: IconsConstants.edit_btn,
//                               height: 30.h,
//                               width: 30.w,
//                               color: AppColors.primary,
//                             ),
//                           ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//
//           /// 🔹 name  + transaction image
//           Row(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(left: 12.0, right: 12, top: 10),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "الإسم : ${reservation.patientName ?? ""}",
//                       style: context.typography.lgBold.copyWith(
//                         color: AppColors.background_black,
//                       ),
//                     ),
//                     const SizedBox(height: 5),
//                     Text(
//                       "الهاتف : ${reservation.patientPhone ?? ""}",
//                       style: context.typography.lgBold.copyWith(
//                         color: AppColors.background_black,
//                       ),
//                     ),
//                     const SizedBox(height: 5),
//                     Text(
//                       "المدفوع :  ${reservation.paidAmount ?? ""}",
//                       style: context.typography.lgBold.copyWith(
//                         color: AppColors.background_black,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               if (transferImage != null && transferImage.isNotEmpty)
//                 InkWell(
//                   onTap: () {
//                     // 🖼️ Open full screen preview
//                     Get.to(
//                       () => FullScreenImageView(imageUrl: transferImage),
//                       transition: Transition.fadeIn,
//                       duration: const Duration(milliseconds: 250),
//                     );
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 12.0, right: 8),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(8),
//                       child: CachedNetworkImage(
//                         imageUrl: transferImage,
//                         fit: BoxFit.cover,
//                         height: 55.w,
//                         width: 85.w,
//                         placeholder: (context, url) => Container(
//                           height: 55.w,
//                           width: 85.w,
//                           color: AppColors.background_neutral_100,
//                           child: const Center(
//                             child: SizedBox(
//                               width: 16,
//                               height: 16,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 1.5,
//                               ),
//                             ),
//                           ),
//                         ),
//                         errorWidget: (context, url, error) => Container(
//                           height: 55.w,
//                           width: 85.w,
//                           color: AppColors.background_neutral_100,
//                           child: const Icon(
//                             Icons.broken_image,
//                             color: Colors.grey,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 )
//               else
//                 const SizedBox(),
//             ],
//           ),
//
//           /// 🔹 Action Buttons (Dynamic by Status)
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//             child: _buildButtons(context, status),
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// 🟢 Build buttons depending on status
//   Widget _buildButtons(BuildContext context, ReservationNewStatus status) {
//     final List<Widget> buttons = [];
//
//     // -----------------------
//     // DETAILS (always first)
//     // -----------------------
//     buttons.add(
//       Expanded(
//         child: PrimaryTextButton(
//           onTap: _showDetails,
//           appButtonSize: AppButtonSize.large,
//           customBackgroundColor: ColorMappingImpl().white,
//           customBorder: BorderSide(
//             color: ColorMappingImpl().borderNeutralPrimary,
//           ),
//           label: AppText(
//             text: "تفاصيل",
//             textStyle: context.typography.mdMedium.copyWith(
//               color: ColorMappingImpl().textDefault,
//             ),
//           ),
//         ),
//       ),
//     );
//
//     // -----------------------
//     // ORDER (if completed)
//     // -----------------------
//     if (reservation.isOrdered != true &&
//         ReservationNewStatus.completed == status) {
//       buttons.add(const SizedBox(width: 8));
//
//       buttons.add(
//         Expanded(
//           child: PrimaryTextButton(
//             onTap: _makeOrder,
//             appButtonSize: AppButtonSize.large,
//             customBackgroundColor: ColorMappingImpl().white,
//             customBorder: BorderSide(
//               color: ColorMappingImpl().borderNeutralPrimary,
//             ),
//             label: AppText(
//               text: "طلب الروشتة",
//               textStyle: context.typography.mdMedium.copyWith(
//                 color: ColorMappingImpl().textDefault,
//               ),
//             ),
//           ),
//         ),
//       );
//     }
//
//
//     switch (status) {
//       case ReservationNewStatus.pending:
//         buttons.add(const SizedBox(width: 8));
//
//         buttons.addAll([
//           Expanded(
//             child: PrimaryTextButton(
//               onTap: () => controller.changeReservationStatus(
//                 reservation: reservation,
//                 newStatus: ReservationStatus.approved,
//               ),
//               appButtonSize: AppButtonSize.large,
//               customBackgroundColor: AppColors.successBackground,
//               label: AppText(
//                 text: "موافقة",
//                 textStyle: context.typography.mdMedium.copyWith(
//                   color: AppColors.successForeground,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: PrimaryTextButton(
//               onTap: () => controller.changeReservationStatus(
//                 reservation: reservation,
//                 newStatus: ReservationStatus.cancelledByAssistant,
//               ),
//               appButtonSize: AppButtonSize.large,
//               customBackgroundColor: AppColors.errorForeground,
//               label: AppText(
//                 text: "إلغاء",
//                 textStyle: context.typography.mdMedium.copyWith(
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//         ]);
//         break;
//
//       case ReservationNewStatus.approved:
//         buttons.add(const SizedBox(width: 8));
//
//         buttons.addAll([
//           Expanded(
//             child: PrimaryTextButton(
//               onTap: () => controller.changeReservationStatus(
//                 reservation: reservation,
//                 newStatus: ReservationStatus.inProgress,
//               ),
//               appButtonSize: AppButtonSize.large,
//               customBackgroundColor: AppColors.primary,
//               label: AppText(
//                 text: "إبدأ الكشف",
//                 textStyle: context.typography.mdMedium.copyWith(
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: PrimaryTextButton(
//               onTap: () => controller.changeReservationStatus(
//                 reservation: reservation,
//                 newStatus: ReservationStatus.cancelledByAssistant,
//               ),
//               appButtonSize: AppButtonSize.large,
//               customBackgroundColor: AppColors.errorForeground,
//               label: AppText(
//                 text: "إلغاء",
//                 textStyle: context.typography.mdMedium.copyWith(
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//         ]);
//         break;
//
//       case ReservationNewStatus.inProgress:
//         buttons.add(const SizedBox(width: 8));
//
//         buttons.add(
//           Expanded(
//             child: PrimaryTextButton(
//               onTap: () => controller.changeReservationStatus(
//                 reservation: reservation,
//                 newStatus: ReservationStatus.completed,
//               ),
//               appButtonSize: AppButtonSize.large,
//               customBackgroundColor: AppColors.background_black,
//               label: AppText(
//                 text: "تم الكشف",
//                 textStyle: context.typography.mdBold.copyWith(
//                   color: AppColors.white,
//                 ),
//               ),
//             ),
//           ),
//         );
//         break;
//
//       default:
//         break;
//     }
//
//     return Row(children: buttons);
//   }
//
//   void _showDetails() {
//     Get.to(
//       () => ReservationAssistantDetailsView(
//         reservation: reservation,
//         controller: controller,
//         index: index,
//       ),
//       binding: Binding(),
//     );
//   }
//
//   void _makeOrder() {
//     if ((reservation.prescriptionUrl1 == null ||
//             reservation.prescriptionUrl1!.isEmpty) &&
//         (reservation.prescriptionUrl2 == null ||
//             reservation.prescriptionUrl2!.isEmpty)) {
//       _showUploadRequiredSheet(Get.context!, reservation);
//       return;
//     }
//
//     openOrderConfirmationSheet(Get.context!, controller, reservation);
//   }
//
//   void _showUploadRequiredSheet(
//     BuildContext context,
//     ReservationModel reservation,
//   ) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: AppColors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
//       ),
//       builder: (_) {
//         return SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Small drag handle
//                 Container(
//                   width: 45,
//                   height: 5,
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade300,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//
//                 const SizedBox(height: 18),
//
//                 Text(
//                   "تنبيه هام",
//                   style: context.typography.xlBold.copyWith(
//                     color: AppColors.textDisplay,
//                   ),
//                 ),
//
//                 const SizedBox(height: 12),
//
//                 Text(
//                   "يجب عليك أولاً رفع صورة الروشتة بعد انتهاء الكشف.\n"
//                   "ستحصل على خصم يصل إلى 10%، وسيتم توصيل العلاج إلى باب منزلك 🚚💊",
//                   textAlign: TextAlign.center,
//                   style: context.typography.mdRegular.copyWith(
//                     color: AppColors.textSecondaryParagraph,
//                   ),
//                 ),
//
//                 const SizedBox(height: 25),
//
//                 // رفع الروشتة
//                 SizedBox(
//                   width: double.infinity,
//                   child: PrimaryTextButton(
//                     appButtonSize: AppButtonSize.xxLarge,
//                     customBackgroundColor: AppColors.primary,
//                     label: AppText(
//                       text: "رفع الروشتة",
//                       textStyle: context.typography.mdBold.copyWith(
//                         color: Colors.white,
//                       ),
//                     ),
//                     onTap: () {
//                       Navigator.pop(context);
//                       controller.prescriptionService.openBottomSheet(
//                         context: context,
//                         reservation: reservation,
//                         onUpdated: () {
//                           controller.getReservations();
//                           controller.update();
//                         },
//                       );
//                     },
//                   ),
//                 ),
//
//                 const SizedBox(height: 12),
//
//                 // إغلاق
//                 SizedBox(
//                   width: double.infinity,
//                   child: PrimaryTextButton(
//                     appButtonSize: AppButtonSize.large,
//                     customBackgroundColor: AppColors.background_neutral_100,
//                     label: AppText(
//                       text: "إغلاق",
//                       textStyle: context.typography.mdMedium.copyWith(
//                         color: AppColors.textDefault,
//                       ),
//                     ),
//                     onTap: () => Navigator.pop(context),
//                   ),
//                 ),
//
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
// }





class ReservationCard extends StatelessWidget {
  final ReservationModel reservation;
  final ReservationViewModel controller;
  final int index;

  const ReservationCard({
    super.key,
    required this.reservation,
    required this.controller,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final status =
    ReservationStatusNewExt.fromValue(reservation.status ?? "");

    final ahead = controller.queueManager.aheadInQueue(
      reservations: controller.listReservations,
      target: reservation,
    );

    final bool isCompletedOrCancelled =
        reservation.status == ReservationNewStatus.completed.value ||
            reservation.status ==
                ReservationNewStatus.cancelledByAssistant.value;

    return Container(
      decoration: BoxDecoration(
        color: reservation.reservationType == "كشف مستعجل"
            ? AppColors.errorForeground.withValues(alpha: 0.15)
            : AppColors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: ColorMappingImpl().borderNeutralPrimary,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReservationCardHeader(
            reservation: reservation,
            controller: controller,
            status: status,
            ahead: ahead,
            isCompletedOrCancelled: isCompletedOrCancelled,

          ),
          ReservationCardBody(reservation: reservation),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 10,
            ),
            child: ReservationCardActions(
              reservation: reservation,
              controller: controller,
            ),
          ),
        ],
      ),
    );
  }
}



