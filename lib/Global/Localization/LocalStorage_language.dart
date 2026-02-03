
import '../../index/index_main.dart';

class LocalStorage_language {
  void inset(String lan) {
    StorageService().setData("lang", lan);
  }

  void remove(String key) {
    StorageService().remove(key);
  }

  String read() {
    if (StorageService().getData("lang") == null) {
      return "en";
    }

    return StorageService().getData("lang");
  }
}
