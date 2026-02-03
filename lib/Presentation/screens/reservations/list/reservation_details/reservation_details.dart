// import '../../../../../../index/index_main.dart';
//
// class ReservationDetailsScreen extends StatelessWidget {
//   final ReservationModel reservation;
//   final ReservationViewModel controller;
//   final int index;
//
//   const ReservationDetailsScreen({
//     super.key,
//     required this.reservation,
//     required this.controller,
//     required this.index,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final status = ReservationStatusExt.fromValue(reservation.status ?? "");
//
//     return Scaffold(
//       backgroundColor: AppColors.white,
//
//       // -------------------------
//       // 🟦 App Bar
//       // -------------------------
//       appBar: AppBar(
//         backgroundColor: AppColors.white,
//         elevation: 0,
//         centerTitle: true,
//         title: Text(
//           "تفاصيل الحجز",
//           style: context.typography.lgBold.copyWith(
//             color: AppColors.textDisplay,
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           color: AppColors.textDisplay,
//           onPressed: () => Get.back(),
//         ),
//       ),
//
//       // -------------------------
//       // 🟫 Body
//       // -------------------------
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // SECTION: Header
//             HeaderSection(
//               reservation: reservation,
//               status: status,
//               controller: controller,
//             ),
//             const SizedBox(height: 14),
//
//             // SECTION: Patient Info
//             PatientInfoSection(reservation: reservation),
//             const SizedBox(height: 14),
//
//             // SECTION: Prescription
//             PrescriptionSection(
//               reservation: reservation,
//               controller: controller,
//               showImage: true,
//             ),
//             const SizedBox(height: 14),
//
//             // SECTION: Reservation Details
//             ReservationDetailsSection(reservation: reservation),
//             const SizedBox(height: 14),
//
//             // SECTION: Doctor Info
//             DoctorInfoSection(reservation: reservation),
//             const SizedBox(height: 14),
//
//             // SECTION: Payment Info
//             PaymentInfoSection(reservation: reservation),
//             const SizedBox(height: 20),
//
//             // SECTION: Buttons
//             ButtonsSection(
//               reservation: reservation,
//               controller: controller,
//               status: status,
//               index: index,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
