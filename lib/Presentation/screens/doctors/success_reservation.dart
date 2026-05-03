// import 'dart:async';
// import 'package:diwanclinic/Global/Constatnts/animations.dart';
// import 'package:diwanclinic/Presentation/design_systems/animation/generic_animation_widget.dart';
// import '../../../../index/index_main.dart';
//
// class ReservationSuccessView extends StatefulWidget {
//   const ReservationSuccessView({super.key});
//
//   @override
//   State<ReservationSuccessView> createState() => _ReservationSuccessViewState();
// }
//
// class _ReservationSuccessViewState extends State<ReservationSuccessView> {
//   Timer? _timer;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // 🔁 Auto navigate safely
//     _timer = Timer(const Duration(seconds: 6), () {
//       if (mounted) {
//         // ✅ يرجع للرئيسية بدون ما يقتل كل الـ controllers
//         Get.offNamed(mainpage)?.then((_) {
//           initController(() => HomePatientController());
//           initController(() => ReservationPatientViewModel());
//         });
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel(); // ✅ يمنع أي memory leak أو crash
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final typography = context.typography;
//
//     return Scaffold(
//       backgroundColor: AppColors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               /// 🎬 Background success animation
//               const GenericAnimationWidget(
//                 animation_file_name: Animations.success,
//               ),
//
//               /// 📋 Overlay content
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   // ✅ Title
//                   Text(
//                     "تم إرسال الحجز بنجاح 🎉",
//                     style: typography.lgBold,
//                     textAlign: TextAlign.center,
//                   ),
//
//                   SizedBox(height: 12.h),
//
//                   // 🩺 Info message
//                   Text(
//                     "الرجاء انتظار تأكيد الحجز من المساعدة.\n"
//                     "ستصلك إشعار فور التأكيد، ويمكنك متابعة دورك بسهولة من التطبيق.",
//                     style: typography.mdMedium.copyWith(height: 1.6),
//                     textAlign: TextAlign.center,
//                   ),
//
//                   SizedBox(height: 80.h),
//
//                   /// 🔘 زر رجوع فوري (أفضل UX)
//                   SizedBox(
//                     width: double.infinity,
//                     height: 55.h,
//                     child: PrimaryTextButton(
//                       label: AppText(
//                         text: "العودة للرئيسية",
//                         textStyle: typography.mdMedium.copyWith(
//                           color: AppColors.white,
//                         ),
//                       ),
//                       onTap: () {
//                         Get.offNamed(mainpage);
//                       },
//                     ),
//                   ),
//
//                   SizedBox(height: 20.h),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
