import 'package:get/get.dart';
import '../Constatnts/TextConstants.dart';
import 'StorageService.dart';

class ForceUpdate extends GetxController {
  static const _key = Strings.force_update;

  final StorageService _storage = StorageService();

  // ============================================================
  // 💾 SAVE
  // ============================================================

  Future<bool> saveAlreadyOpen(bool isUpdate) {
    return _storage.setData(_key, {"value": isUpdate});
  }

  // ============================================================
  // 📖 READ
  // ============================================================

  bool getOpen() {
    final data = _storage.getData(_key);

    if (data == null) return false;

    return data["value"] == true;
  }

  // ============================================================
  // ❌ CLEAR
  // ============================================================

  Future<void> clear() async {
    await _storage.remove(_key);
  }
}
