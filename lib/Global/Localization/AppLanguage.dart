// ignore_for_file: unnecessary_null_comparison, unrelated_type_equality_checks



import '../../index/index_main.dart';

class AppLanguage extends GetxController {
  var appLocale = 'ar';

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();
    LocalStorage_language localStorage = LocalStorage_language();
    appLocale = localStorage.read();
    Get.updateLocale(Locale(appLocale));
    update();
  }

  void changeLanguage(String type) async {
    LocalStorage_language localStorage = LocalStorage_language();

    if (localStorage.read() == type) {
      return;
    }
    if (type == "ar") {
      localStorage.inset("ar");
      appLocale = "ar";
    } else {
      localStorage.inset("en");
      appLocale = "en";
    }
    print(" app local is $appLocale");
    Get.updateLocale(Locale(appLocale));
  }
}
