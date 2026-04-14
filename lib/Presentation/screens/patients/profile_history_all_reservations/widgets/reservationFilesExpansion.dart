// import 'dart:io';
// import 'package:file_picker/file_picker.dart';
// import '../../../../../index/index_main.dart';
//
// class ReservationFilesExpansion extends StatefulWidget {
//   final ReservationModel reservation;
//   final HandleKeyboardService keyboardService;
//   final List<String> keys;
//   final bool initiallyExpanded;
//   final PatientProfileAllHistoryViewModel controller;
//
//   const ReservationFilesExpansion({
//     super.key,
//     required this.reservation,
//     required this.keyboardService,
//     required this.keys,
//     required this.controller,
//     this.initiallyExpanded = false,
//   });
//
//   @override
//   State<ReservationFilesExpansion> createState() =>
//       _ReservationFilesExpansionState();
// }
//
// class _ReservationFilesExpansionState extends State<ReservationFilesExpansion> {
//   late final TextEditingController tempController;
//   late final TextEditingController weightController;
//   late final TextEditingController heightController;
//   late final TextEditingController diagnosisController;
//   late final TextEditingController allergyController;
//
//   @override
//   void initState() {
//     super.initState();
//     tempController = TextEditingController(
//       text: widget.reservation.temperature ?? "",
//     );
//     weightController = TextEditingController(
//       text: widget.reservation.weight ?? "",
//     );
//     heightController = TextEditingController(
//       text: widget.reservation.height ?? "",
//     );
//     diagnosisController = TextEditingController(
//       text: widget.reservation.diagnosis ?? "",
//     );
//     allergyController = TextEditingController(
//       text: widget.reservation.allergies ?? "",
//     );
//   }
//
//   @override
//   void dispose() {
//     tempController.dispose();
//     weightController.dispose();
//     heightController.dispose();
//     diagnosisController.dispose();
//     allergyController.dispose();
//     super.dispose();
//   }
//
//   Future<void> pickFile() async {
//     final result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
//     );
//
//     if (result != null && result.files.single.path != null) {
//       final pickedFile = File(result.files.single.path!);
//     }
//   }
//
//   String normalizeArabic(String? text) {
//     return text
//             ?.replaceAll(RegExp(r'[\u200E\u200F\u202A-\u202E]'), '')
//             .trim() ??
//         '';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final reservation = widget.reservation;
//     final String status = normalizeArabic(reservation.status);
//     final String type = normalizeArabic(reservation.reservationType);
//
//     final bool isEditable =
//         status != "completed" && (type == "كشف جديد" || type == "كشف مستعجل");
//
//     final List<String> prescriptionUrls = [
//       if ((reservation.prescriptionUrl1 ?? '').isNotEmpty)
//         reservation.prescriptionUrl1!,
//       if ((reservation.prescriptionUrl2 ?? '').isNotEmpty)
//         reservation.prescriptionUrl2!,
//     ];
//
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       elevation: 1,
//       child: ExpansionTile(
//         initiallyExpanded: widget.initiallyExpanded,
//         tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         backgroundColor: AppColors.primary_light,
//         collapsedBackgroundColor: AppColors.primary_light,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         collapsedShape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         title: Row(
//           children: [
//             const Icon(Icons.event_note, color: AppColors.primary, size: 22),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 "${reservation.appointmentDateTime ?? "-"} • ${reservation.reservationType ?? ""}",
//                 style: context.typography.mdBold.copyWith(
//                   color: AppColors.primary,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         children: [
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(16),
//             decoration: const BoxDecoration(
//               color: AppColors.white,
//               borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (isEditable) ...[
//                   /// 🔹 Editable inputs
//                   CustomInputField(
//                     label: "التشخيص",
//                     hintText: "أدخل التشخيص",
//                     controller: diagnosisController,
//                     keyboardType: TextInputType.text,
//                     voidCallbackAction: (value) =>
//                         reservation.diagnosis = value,
//                     focusNode: widget.keyboardService.getFocusNode(
//                       widget.keys[0],
//                     ),
//                     validator: (String? p1) {},
//                   ),
//                   const SizedBox(height: 12),
//                   CustomInputField(
//                     label: "أمراض أو حساسية",
//                     hintText: "أدخل الأمراض أو الحساسية",
//                     controller: allergyController,
//                     keyboardType: TextInputType.text,
//                     voidCallbackAction: (value) =>
//                         reservation.allergies = value,
//                     focusNode: widget.keyboardService.getFocusNode(
//                       widget.keys[1],
//                     ),
//                     validator: (String? p1) {},
//                   ),
//                   const SizedBox(height: 20),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: AppTextField(
//                           hintText: "درجة الحرارة",
//                           controller: tempController,
//                           keyboardType: TextInputType.number,
//                           onChanged: (v) => reservation.temperature = v,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: AppTextField(
//                           hintText: "الوزن",
//                           controller: weightController,
//                           keyboardType: TextInputType.number,
//                           onChanged: (v) => reservation.weight = v,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: AppTextField(
//                           hintText: "الطول",
//                           controller: heightController,
//                           keyboardType: TextInputType.number,
//                           onChanged: (v) => reservation.height = v,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ] else ...[
//                   /// 🔹 Read-only view
//                   InfoRowWidget(
//                     label: "التشخيص",
//                     value: reservation.diagnosis ?? "-",
//                   ),
//                   InfoRowWidget(
//                     label: "الحساسية",
//                     value: reservation.allergies ?? "-",
//                   ),
//                   const Divider(),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: InfoColumnWidget(
//                           label: "الحرارة",
//                           value: reservation.temperature ?? "-",
//                         ),
//                       ),
//                       Expanded(
//                         child: InfoColumnWidget(
//                           label: "الوزن",
//                           value: reservation.weight ?? "-",
//                         ),
//                       ),
//                       Expanded(
//                         child: InfoColumnWidget(
//                           label: "الطول",
//                           value: reservation.height ?? "-",
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//
//                 /// 🔹 Prescription Section
//                 const SizedBox(height: 16),
//                 Text(
//                   "الروشتة",
//                   style: context.typography.lgBold.copyWith(
//                     color: AppColors.text_primary_paragraph,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 if (prescriptionUrls.isEmpty)
//                   isEditable
//                       ? GestureDetector(
//                           onTap: pickFile,
//                           child: Container(
//                             height: 45,
//                             decoration: BoxDecoration(
//                               color: AppColors.background_neutral_100,
//                               borderRadius: BorderRadius.circular(8),
//                               border: Border.all(color: AppColors.primary),
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 const Icon(
//                                   Icons.upload_file,
//                                   color: AppColors.primary,
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   'تحميل الروشتة',
//                                   style: context.typography.mdMedium.copyWith(
//                                     color: AppColors.primary,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         )
//                       : Container(
//                           padding: const EdgeInsets.all(10),
//                           decoration: BoxDecoration(
//                             color: AppColors.background_neutral_100,
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Row(
//                             children: [
//                               const Icon(
//                                 Icons.medical_information_outlined,
//                                 color: AppColors.textSecondaryParagraph,
//                               ),
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 child: Text(
//                                   "لا توجد روشتة مرفقة لهذا الكشف",
//                                   style: context.typography.smRegular.copyWith(
//                                     color: AppColors.textSecondaryParagraph,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         )
//                 else
//                   SizedBox(
//                     height: 80,
//                     child: ListView.separated(
//                       scrollDirection: Axis.horizontal,
//                       itemCount: prescriptionUrls.length,
//                       separatorBuilder: (_, __) => const SizedBox(width: 8),
//                       itemBuilder: (_, i) => GestureDetector(
//                         onTap: () => Get.to(
//                           () => FullScreenImageView(
//                             imageUrl: prescriptionUrls[i],
//                           ),
//                         ),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(8),
//                           child: CachedNetworkImage(
//                             imageUrl: prescriptionUrls[i],
//                             fit: BoxFit.cover,
//                             height: 70,
//                             width: 100,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
