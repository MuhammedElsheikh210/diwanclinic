//
// import '../../../../index/index_main.dart';
//
// class OTPView extends GetView<OtpViewModel> {
//   KeyboardActionsConfig buildConfig(BuildContext context) {
//     return KeyboardActionsConfig(
//       defaultDoneWidget: const TextWidget(
//           title: "Done",
//           color: ColorResources.COLOR_Primary,
//           fontWeight: FontWeight.w500,
//           fontSize: 14),
//       keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
//       keyboardBarColor: Colors.grey[300],
//       nextFocus: true,
//       actions: [
//         KeyboardActionsItem(
//           focusNode: controller.myFocusNode,
//         ),
//         KeyboardActionsItem(
//           focusNode: controller.myFocusNode2,
//         ),
//         KeyboardActionsItem(
//           focusNode: controller.myFocusNode3,
//         ),
//         KeyboardActionsItem(
//           focusNode: controller.myFocusNode4,
//         ),
//       ],
//     );
//   }
//
//   const OTPView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle.light,
//       child: Scaffold(
//         appBar: const AppBarWithTitleAndBack(title: "OTP"),
//         backgroundColor: ColorResources.COLOR_white,
//         bottomNavigationBar: SafeArea(
//           child: BottomNavigationView(
//               leftwidget: Expanded(
//                 flex: 2,
//                 child: CustomButtonWidget(
//                   width: MediaQuery.of(context).size.width,
//                   height: 70,
//                   onpress: () {
//                     // NavigationGet().route_name(successfullyVerificationView);
//                     controller.otpData();
//                   },
//                   backgroundcolor: ColorResources.COLOR_Primary,
//                   borderradius: 20,
//                   text: const Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       TextWidget(
//                           title: "Verify",
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: ColorResources.COLOR_white),
//                       SizedBox(
//                         width: 8,
//                       ),
//                       Icon(
//                         Icons.arrow_forward,
//                         color: ColorResources.COLOR_white,
//                         size: 15,
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//               rightwidget: Expanded(
//                 flex: 3,
//                 child: // counter
//                     GetBuilder<OtpViewModel>(builder: (controller) {
//                   return TextWidget(
//                     title: "00:${controller.SCount}",
//                     fontWeight: FontWeight.w700,
//                     fontSize: 15,
//                     color: ColorResources.COLOR_GreenDark,
//                   );
//                 }),
//               )),
//         ),
//         body: KeyboardActions(
//           config: buildConfig(context),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               GetBuilder<OtpViewModel>(
//                   init: OtpViewModel(),
//                   builder: (controller) {
//                     return Container(
//                       margin: const EdgeInsets.symmetric(horizontal: 60),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Directionality(
//                             textDirection: TextDirection.ltr,
//                             child: OtpCustomWidget(
//                                 controller: controller,
//                                 onOtpEntered: (codevalue) {
//                                   controller.isFill = true;
//                                   controller.code = codevalue;
//                                   controller.update();
//                                 }),
//                           ),
//                           const SizedBox(
//                             height: 30,
//                           ),
//                           // resend button
//                           Visibility(
//                             visible: controller.isTimerEnded,
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 const TextWidget(
//                                     title: "You don’t receive it? ",
//                                     fontSize: 14,
//                                     lineHeight: 1.5,
//                                     fontWeight: FontWeight.w500,
//                                     maxLine: 2,
//                                     color: ColorResources.COLOR_BLACK),
//                                 GestureDetector(
//                                   onTap: () {
//                                     controller.resendOtpAction();
//                                   },
//                                   child: TextWidget(
//                                       decoration: TextDecoration.underline,
//                                       title: "Resend it".tr,
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w500,
//                                       color: ColorResources.COLOR_Primary),
//                                 ),
//                               ],
//                             ),
//                           ),
//
//                           TextWidget(
//                               title:
//                                   "we will send you an OTP message on\nthis phone ${controller.phoneValue}",
//                               fontSize: 14,
//                               lineHeight: 1.5,
//                               textAlign: TextAlign.center,
//                               fontWeight: FontWeight.w500,
//                               maxLine: 2,
//                               color: ColorResources.COLOR_BLACK),
//                         ],
//                       ),
//                     );
//                   })
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
