import '../../index/index_main.dart';

class AppLanguage extends GetxController {
  final LocalStorageLanguage _storage = LocalStorageLanguage();

  // ============================================================
  // 🌍 STATE
  // ============================================================

  final appLocale = 'ar'.obs;

  // ============================================================
  // 🚀 INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    final savedLang = _storage.read();

    appLocale.value = savedLang;
    Get.updateLocale(Locale(savedLang));
  }

  // ============================================================
  // 🔄 CHANGE LANGUAGE
  // ============================================================

  Future<void> changeLanguage(String lang) async {
    if (appLocale.value == lang) return;

    await _storage.save(lang);

    appLocale.value = lang;

    Get.updateLocale(Locale(lang));

    debugPrint("🌍 App language changed to: $lang");
  }
}
