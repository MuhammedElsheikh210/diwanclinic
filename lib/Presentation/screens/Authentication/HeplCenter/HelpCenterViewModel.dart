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

  Future<void> openWhatsapp() async {
    const phone = '201551061194'; // بدون +

    final message = Uri.encodeComponent("سلام عليكم".tr);

    final whatsappUri = Uri.parse('whatsapp://send?phone=$phone&text=$message');

    try {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      throw 'Could not launch WhatsApp';
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
