import '../../index/index_main.dart';

class LocalStorageLanguage {
  static const _key = "lang";

  final StorageService _storage = StorageService();

  // ============================================================
  // 💾 SAVE
  // ============================================================

  Future<bool> save(String lang) {
    return _storage.setData(_key, {"value": lang});
  }

  // ============================================================
  // 📖 READ
  // ============================================================

  String read() {
    final data = _storage.getData(_key);

    if (data == null) return "en";

    return data["value"] ?? "en";
  }

  // ============================================================
  // ❌ CLEAR
  // ============================================================

  Future<void> clear() async {
    await _storage.remove(_key);
  }
}
