
import '../../../../index/index_main.dart';

class LocalUserRepository {
  final LocalUserDataSource _dataSource;

  const LocalUserRepository(this._dataSource);

  // ============================================================
  // GET USER
  // ============================================================

  LocalUser? getUser() {
    return _dataSource.get();
  }

  // ============================================================
  // SAVE USER
  // ============================================================

  Future<void> saveUser(LocalUser user) async {
    await _dataSource.save(user);
  }

  // ============================================================
  // CLEAR USER
  // ============================================================

  Future<void> clearUser() async {
    await _dataSource.remove();
  }

  // ============================================================
  // HELPERS (🔥 مهمة جدًا)
  // ============================================================

  bool get hasUser => _dataSource.get() != null;

  UserType? get userType => _dataSource.get()?.user.userType;
}