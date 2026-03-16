// import '../../../../index/index_main.dart';
//
// class LegacyQueueDateAppBar extends StatelessWidget
//     implements PreferredSizeWidget {
//   final LegacyQueueViewModel controller;
//
//   const LegacyQueueDateAppBar({super.key, required this.controller});
//
//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       backgroundColor: AppColors.white,
//       elevation: 0,
//       toolbarHeight: 92.h,
//       leading: const BackButton(),
//       titleSpacing: 0,
//       title: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 14),
//         child: Row(
//           children: [
//             /// 📅 Date
//             Expanded(
//               child: InkWell(
//                 onTap: () => _showDatePicker(context),
//                 child: Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(14),
//                     border: Border.all(
//                       color: AppColors.grayLight.withOpacity(0.4),
//                       width: 2,
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         controller.formattedDate,
//                         style: context.typography.lgBold,
//                       ),
//                       const SizedBox(width: 8),
//                       const Icon(Icons.keyboard_arrow_down_rounded),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//
//             /// 🕒 Shift Badge
//             if (controller.shiftDropdownItems != null &&
//                 controller.shiftDropdownItems!.length > 1 &&
//                 controller.selectedShift != null) ...[
//               const SizedBox(width: 10),
//               GestureDetector(
//                 onTap: controller.showMandatoryShiftDialog,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 8,
//                   ),
//                   decoration: BoxDecoration(
//                     color: AppColors.primary.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Row(
//                     children: [
//                       const Icon(
//                         Icons.schedule,
//                         size: 18,
//                         color: AppColors.primary,
//                       ),
//                       const SizedBox(width: 6),
//                       Text(
//                         controller.selectedShift?.name ?? "",
//                         style: context.typography.smMedium.copyWith(
//                           color: AppColors.primary,
//                         ),
//                       ),
//                       const SizedBox(width: 4),
//                       const Icon(
//                         Icons.keyboard_arrow_down_rounded,
//                         size: 18,
//                         color: AppColors.primary,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showDatePicker(BuildContext context) {
//     final calenderVM = Get.put(CalenderViewModel());
//
//     calenderVM.showIOSDatePicker(
//       context,
//       controller.selectedDate.millisecondsSinceEpoch,
//       (timestamp, _) {
//         controller.onDateChanged(timestamp.toDate());
//       },
//     );
//   }
//
//   @override
//   Size get preferredSize => Size.fromHeight(92.h);
// }
