// import 'package:intl/intl.dart';
// import '../../../../index/index_main.dart';
//
// class OpenclosereservationDateAppBar extends StatelessWidget
//     implements PreferredSizeWidget {
//   final OpenclosereservationViewModel controller;
//
//   const OpenclosereservationDateAppBar({
//     super.key,
//     required this.controller,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     /// 🧠 اليوم الحالي مقفول؟
//     final bool isClosedDay = controller.list != null &&
//         controller.list!.isNotEmpty &&
//         controller.list!.first?.isClosed == true;
//
//     return AppBar(
//       backgroundColor: AppColors.white,
//       elevation: 0,
//       automaticallyImplyLeading: false,
//       toolbarHeight: 92.h,
//       centerTitle: false,
//       titleSpacing: 0,
//       leading: const BackButton(),
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
//                     color: AppColors.white,
//                     borderRadius: BorderRadius.circular(14),
//                     border: Border.all(
//                       color: isClosedDay
//                           ? AppColors.errorForeground.withOpacity(0.6)
//                           : AppColors.grayLight.withOpacity(0.4),
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
//             /// 🕒 Shift Badge (لو أكتر من شيفت)
//             if (controller.shiftDropdownItems != null &&
//                 controller.shiftDropdownItems!.length > 1 &&
//                 controller.selectedShift != null) ...[
//               const SizedBox(width: 10),
//               GestureDetector(
//                 onTap: controller.showMandatoryShiftDialog,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 12, vertical: 8),
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
//       bottom: PreferredSize(
//         preferredSize: const Size.fromHeight(1),
//         child: Container(
//           height: 1,
//           color: AppColors.borderNeutralPrimary.withOpacity(0.6),
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
//           (timestamp, formattedDate) {
//         controller.onDateChanged(timestamp.toDate());
//       },
//     );
//   }
//
//   @override
//   Size get preferredSize => Size.fromHeight(92.h);
// }
