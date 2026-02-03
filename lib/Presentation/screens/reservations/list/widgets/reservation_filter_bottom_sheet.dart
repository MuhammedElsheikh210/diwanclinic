// import 'package:intl/intl.dart';
//
// import '../../../../../index/index_main.dart';
//
// /// 🔹 Bottom sheet used to filter reservations by:
// /// - Clinic
// /// - Shift
// /// - Status
// /// - Date (using custom CalenderWidget)
// class ReservationFilterBottomSheet extends StatelessWidget {
//   final ReservationViewModel controller;
//
//   const ReservationFilterBottomSheet({super.key, required this.controller});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         color: ColorResources.COLOR_white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//       ),
//       padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 25.h),
//       child: SingleChildScrollView(
//         physics: const BouncingScrollPhysics(),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             /// ------------------------------------------------------------
//             /// 🔹 Header Section
//             /// ------------------------------------------------------------
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   "فلترة الحجوزات",
//                   style: context.typography.lgBold.copyWith(
//                     color: ColorResources.COLOR_Primary,
//                   ),
//                 ),
//                 InkWell(
//                   onTap: () => Get.back(),
//                   child: const Icon(
//                     Icons.close,
//                     color: ColorResources.COLOR_GrayDark,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 25.h),
//
//             /// ------------------------------------------------------------
//             /// 🔹 Clinic Dropdown
//             /// ------------------------------------------------------------
//             // Text(
//             //   "العيادة",
//             //   style: context.typography.mdMedium.copyWith(
//             //     color: ColorResources.COLOR_BLACK,
//             //   ),
//             // ),
//             // SizedBox(height: 10.h),
//             // GenericDropdown<GenericListModel>(
//             //   hint_text: "اختر العيادة",
//             //   title: "اختر العيادة",
//             //   show_title: false,
//             //   items: controller.clinicDropdownItems ?? [],
//             //   initialValue: controller.selectedClinic != null
//             //       ? GenericListModel(
//             //           key: controller.selectedClinic!.key ?? "",
//             //           name: controller.selectedClinic!.title,
//             //         )
//             //       : null,
//             //   onChanged: (value) async {
//             //     final selectedClinicKey = value.key ?? "";
//             //     controller.selectedClinic = ClinicModel(
//             //       key: selectedClinicKey,
//             //       title: value.name,
//             //     );
//             //     await controller.getShiftList(selectedClinicKey);
//             //
//             //     controller.update();
//             //   },
//             //   displayItemBuilder: (item) => Text(
//             //     item.name ?? "",
//             //     style: context.typography.smRegular.copyWith(
//             //       color: ColorResources.COLOR_GrayDark,
//             //     ),
//             //   ),
//             // ),
//             //
//             // SizedBox(height: 20.h),
//
//             /// ------------------------------------------------------------
//             /// 🔹 Shift Dropdown
//             /// ------------------------------------------------------------
//             // Text(
//             //   "الوردية",
//             //   style: context.typography.mdMedium.copyWith(
//             //     color: ColorResources.COLOR_BLACK,
//             //   ),
//             // ),
//             // SizedBox(height: 10.h),
//             // GenericDropdown<GenericListModel>(
//             //   hint_text: "اختر الوردية",
//             //   title: "اختر الوردية",
//             //   show_title: false,
//             //   items: controller.shiftDropdownItems ?? [],
//             //   initialValue: controller.selectedShift,
//             //   onChanged: (value) {
//             //     controller.selectedShift = value;
//             //     controller.update();
//             //   },
//             //   displayItemBuilder: (item) => Text(
//             //     item.name ?? "",
//             //     style: context.typography.smRegular.copyWith(
//             //       color: ColorResources.COLOR_GrayDark,
//             //     ),
//             //   ),
//             // ),
//             //
//             // SizedBox(height: 20.h),
//
//             /// ------------------------------------------------------------
//             /// 🔹 Status Dropdown
//             /// ------------------------------------------------------------
//             /// ------------------------------------------------------------
//             /// 🔹 Status Dropdown (with "All" option)
//             /// ------------------------------------------------------------
//             Text(
//               "حالة الحجز",
//               style: context.typography.mdMedium.copyWith(
//                 color: ColorResources.COLOR_BLACK,
//               ),
//             ),
//             SizedBox(height: 5.h),
//             GenericDropdown<GenericListModel>(
//               hint_text: "اختر الحالة",
//               title: "اختر الحالة",
//               show_title: false,
//
//               // ✅ Add "All" as the first option
//               items: [
//                 GenericListModel(key: "all", name: "الكل"),
//                 ...ReservationStatus.values.map(
//                   (status) =>
//                       GenericListModel(key: status.value, name: status.label),
//                 ),
//               ],
//
//               // ✅ Preselect current status
//               initialValue: controller.selectedStatus != null
//                   ? GenericListModel(
//                       key: controller.selectedStatus!.value,
//                       name: controller.selectedStatus!.label,
//                     )
//                   : GenericListModel(key: "all", name: "الكل"),
//
//               onChanged: (value) {
//                 if (value.key == "all") {
//                   controller.selectedStatus = null; // clear status filter
//                 } else {
//                   controller.selectedStatus = ReservationStatusExt.fromValue(
//                     value.key ?? "",
//                   );
//                 }
//                 controller.update();
//               },
//
//               displayItemBuilder: (item) => Text(
//                 item.name ?? "",
//                 style: context.typography.smRegular.copyWith(
//                   color: ColorResources.COLOR_GrayDark,
//                 ),
//               ),
//             ),
//
//             SizedBox(height: 20.h),
//
//             /// ------------------------------------------------------------
//             /// 🔹 Date Selector (using CalenderWidget)
//             /// ------------------------------------------------------------
//             Text(
//               "اليوم",
//               style: context.typography.mdMedium.copyWith(
//                 color: ColorResources.COLOR_BLACK,
//               ),
//             ),
//             SizedBox(height: 10.h),
//             CalenderWidget(
//               hintText: "تاريخ الحجز",
//               initialTimestamp:
//                   controller.create_at ?? DateTime.now().millisecondsSinceEpoch,
//               onDateSelected: (timestamp, formattedDate) {
//                 // 🔹 Convert Firebase Timestamp → DateTime
//                 final date = timestamp.toDate();
//
//                 // 🔹 Format to "dd/MM/yyyy"
//                 final formatted = DateFormat('dd/MM/yyyy').format(date);
//
//                 controller.appointment_date_time = formatted; // 🗓️ String date
//                 controller.create_at =
//                     date.millisecondsSinceEpoch; // ⏱️ Numeric timestamp
//                 controller.update();
//               },
//             ),
//
//             SizedBox(height: 30.h),
//
//             /// ------------------------------------------------------------
//             /// 🔹 Apply Filter Button
//             /// ------------------------------------------------------------
//             SizedBox(
//               width: double.infinity,
//               height: 48.h,
//               child: PrimaryTextButton(
//                 onTap: () {
//                   Get.back();
//                   controller.getReservations();
//                 },
//                 label: AppText(
//                   text: "تطبيق الفلتر",
//                   textStyle: context.typography.mdBold.copyWith(
//                     color: ColorResources.COLOR_white,
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 10.h),
//           ],
//         ),
//       ),
//     );
//   }
// }
