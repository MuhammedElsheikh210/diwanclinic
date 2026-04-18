
import '../../../../index/index_main.dart';

class LocalUserDataSource {
  final StorageService _storage;

  const LocalUserDataSource(this._storage);

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> save(LocalUser user) async {
    final success = await _storage.setData(
      Strings.userkey,
      user.toJson(),
    );

    if (!success) {
      throw Exception('Failed to save user locally');
    }
  }

  // ============================================================
  // GET
  // ============================================================

  LocalUser? get() {
    try {
      final data = _storage.getData(Strings.userkey);

      if (data != null) {
        return LocalUser.fromMap(data);
      }

      return null;
    } catch (e) {
      // مهم جدًا علشان لو حصل corruption
      
      return null;
    }
  }

  // ============================================================
  // REMOVE
  // ============================================================

  Future<void> remove() async {
    await _storage.remove(Strings.userkey);
  }
}