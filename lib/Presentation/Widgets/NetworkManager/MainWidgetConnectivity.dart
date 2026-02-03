// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import '../../../../../Global/index_data.dart';
//
// import 'package:brand/Presentation/Widgets/TextWidget.dart';
//
//
// import 'NetworkManager.dart';
//
// class MainWidgetConnectivity extends StatelessWidget {
//   const MainWidgetConnectivity(
//       {Key? key, required this.child, this.statusbarcolor, this.statusbartheme})
//       : super(key: key);
//   final Widget child;
//   final Color? statusbarcolor;
//   final StatusBarTheme? statusbartheme;
//
//   @override
//   Widget build(BuildContext context) {
//     Loader.dismiss();
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: ThemeHelper().themeValue() == StatusBarTheme.light
//           ? SystemUiOverlayStyle.light
//           : SystemUiOverlayStyle.dark,
//       child: Scaffold(
//         body: Container(
//           color: statusbarcolor ?? ColorResources().COLOR_white,
//           child: GetBuilder<GetXNetworkManager>(
//               init: GetXNetworkManager(),
//               builder: (manager) {
//                 return manager.connectionType == null
//                     ? Container()
//                     : manager.connectionType == 0
//                         ? Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 Image.asset(Images.nowifi,
//                                     height: 300.h,
//                                     width: 300.w,
//                                     color: ColorResources().COLOR_Primary),
//                                 SizedBox(
//                                   height: 50.h,
//                                 ),
//                                 TextWidget(
//                                   title: "No Internet Connection".tr,
//                                   color: ColorResources().COLOR_Primary,
//                                   fontWeight: FontWeight.w700,
//                                   fontSize: 20,
//                                 )
//                               ],
//                             ),
//                           )
//                         : SafeArea(child: child);
//               }),
//         ),
//       ),
//     );
//   }
// }
