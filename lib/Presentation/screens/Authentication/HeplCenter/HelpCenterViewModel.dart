// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

import '../../../../index/index_main.dart';

class HelpCenterViewModel extends GetxController {
  // GlobalModel? globalModel;

  @override
  onInit() {
    globalData();
    super.onInit();
  }

  globalData() {
    // getGlobalData(voidCallBack: (model) {
    //   globalModel = model;
    //   
    //   update();
    // });
  }

  Future<void> openwhatsapp() async {
    // var whatsapp = phone;
    //  var whatsapp = globalModel?.whatsphone ?? "";
    var whatsapp = "+201551061194";

    var whatsappURl_android =
        "whatsapp://send?phone=$whatsapp&text=${"سلام عليكم".tr}";
    var whatappURL_ios =
        "https://wa.me/$whatsapp?text=${Uri.parse("سلام عليكم".tr)}";
    if (Platform.isIOS) {
      // for iOS phone only

      if (!await launchUrl(Uri.parse(whatappURL_ios))) {
        throw 'Could not launch $whatappURL_ios';
      } else {
        //     Loader.showError("there is something error in phone number");
      }
    } else {
      // android , web
      

      if (!await launchUrl(Uri.parse(whatsappURl_android))) {
        throw 'Could not launch $whatsappURl_android';
      } else {
        //   Loader.showError("there is something error in phone number");
      }
    }
  }

  // Make a Phone Call
  Future<void> makeCall() async {
    // var phoneNumber = globalModel?.supportPhone ?? "";
    var phoneNumber = "+201551061194";
    final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);

    if (!await launchUrl(callUri)) {
      throw 'Could not make a call to $phoneNumber';
    }
  }
}
