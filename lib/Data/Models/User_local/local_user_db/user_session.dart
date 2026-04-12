import 'package:diwanclinic/Data/Models/User_local/local_user_db/local_user_repository.dart';

import '../../../../index/index_main.dart';

class UserSession extends GetxService {
  final LocalUserRepository _repo;

  UserSession(this._repo);

  LocalUser? _user;

  // ============================================================
  // INIT (🔥 مهمة جدًا)
  // ============================================================

  Future<UserSession> init() async {
    _user = _repo.getUser();
    return this;
  }

  // ============================================================
  // GET USER (CACHED)
  // ============================================================

  LocalUser? get user => _user;

  bool get isLoggedIn => _user != null;

  bool get isDoctor => _user?.isDoctor ?? false;
  bool get isAssistant => _user?.isAssistant ?? false;

  // ============================================================
  // ACCESS SHORTCUTS
  // ============================================================

  DoctorUser? get doctor => _user?.asDoctor;
  AssistantUser? get assistant => _user?.asAssistant;

  // ============================================================
  // SET USER
  // ============================================================

  Future<void> setUser(LocalUser user) async {
    _user = user;
    await _repo.saveUser(user);
  }

  // ============================================================
  // UPDATE USER (🔥 مهم جدًا)
  // ============================================================

  Future<void> updateUser(BaseUser updatedUser) async {
    if (_user == null) return;

    _user = LocalUser(updatedUser);
    await _repo.saveUser(_user!);
  }

  // ============================================================
  // CLEAR SESSION (LOGOUT)
  // ============================================================

  Future<void> clear() async {
    _user = null;
    await _repo.clearUser();
  }
}