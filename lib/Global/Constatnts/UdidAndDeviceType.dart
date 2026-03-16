import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

class ConstantsData {
  static String deviceType() {
    String os = Platform.operatingSystem; //in your code
    print("deviceType $os");
    return os;
  }

  static Future<String?> udid() async {
    // String udid = await Udid.udid;
    return "udid";
  }

  static Future<String?> firebaseToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    // print("token in fb is $token");
    return token;
  }
}
