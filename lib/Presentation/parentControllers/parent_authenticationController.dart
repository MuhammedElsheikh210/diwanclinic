// ignore_for_file: avoid_renaming_method_parameters

import 'dart:async';
import '../../index/index_main.dart';

class AuthenticationService {
  // ============================================================
  // 🧠 SINGLETON
  // ============================================================

  static final AuthenticationService _instance =
  AuthenticationService._internal();

  factory AuthenticationService() => _instance;

  AuthenticationService._internal();

  final AuthenticationUseCases useCase = initController(
        () => AuthenticationUseCases(Get.find()),
  );

  // ============================================================
  // 🎧 REALTIME CALLBACKS
  // ============================================================

  Function(LocalUser user)? onClientAdded;
  Function(LocalUser user)? onClientUpdated;
  Function(String key)? onClientRemoved;

  StreamSubscription? _addedSub;
  StreamSubscription? _changedSub;
  StreamSubscription? _removedSub;

  bool _isListening = false;

  // ============================================================
  // 🔥 REALTIME SYNC
  // ============================================================

  Future<void> startListening() async {
    if (_isListening) return;

    await useCase.startListening();

    _addedSub = useCase.onAdded.listen((user) {
      onClientAdded?.call(user);
    });

    _changedSub = useCase.onChanged.listen((user) {
      onClientUpdated?.call(user);
    });

    _removedSub = useCase.onRemoved.listen((key) {
      onClientRemoved?.call(key);
    });

    _isListening = true;
  }

  // ============================================================
  // ➕ ADD CLIENT (OLD NAME KEPT)
  // ============================================================

  Future<void> addClientsData({
    required LocalUser userclient,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    final result = await useCase.addClient(userclient);

    result.fold(
          (l) => voidCallBack(ResponseStatus.error),
          (r) => voidCallBack(ResponseStatus.success),
    );
  }

  // ============================================================
  // 🔄 UPDATE CLIENT (OLD NAME KEPT)
  // ============================================================

  Future<void> updateClientsData({
    required LocalUser userclient,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    final result = await useCase.updateClient(userclient);

    result.fold(
          (l) => voidCallBack(ResponseStatus.error),
          (r) => voidCallBack(ResponseStatus.success),
    );
  }

  // ============================================================
  // ❌ DELETE CLIENT (OLD NAME KEPT)
  // ============================================================

  Future<void> deleteClientsData({
    required String uid,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    final result = await useCase.deleteClient(uid);

    result.fold(
          (l) => voidCallBack(ResponseStatus.error),
          (r) => voidCallBack(ResponseStatus.success),
    );
  }

  // ============================================================
  // 📦 GET CLIENTS (LOCAL)
  // ============================================================

  Future<void> getClientsData({
    required SQLiteQueryParams query,
    required Function(List<LocalUser>) voidCallBack,
  }) async {
    final result = await useCase.getClients(query);

    result.fold(
          (l) => Loader.showError("حدث خطأ أثناء جلب العملاء"),
          (r) => voidCallBack(r),
    );
  }

  // ============================================================
  // 🌐 GET CLIENTS (ONLINE ONLY - BULK)
  // ============================================================

  Future<void> getClientsOnlineData({
    required FirebaseFilter firebaseFilter,
    required Function(List<LocalUser>) voidCallBack,
  }) async {
    final result = await useCase.getClientsOnline(firebaseFilter.toJson());

    result.fold(
          (l) => Loader.showError("Network error while loading users"),
          (r) => voidCallBack(r),
    );
  }

  // ============================================================
  // ✅ NEW: GET CLIENT (ONLINE ONLY - LOGIN)
  // ============================================================

  Future<void> getClientByUidOnline({
    required String uid,
    required Function(LocalUser? user) voidCallBack,
  }) async {
    final result = await useCase.getClientByUidOnline(uid);

    result.fold(
          (l) {
        Loader.showError("Network error أثناء تسجيل الدخول");
        voidCallBack(null);
      },
          (user) => voidCallBack(user),
    );
  }

  // ============================================================
  // 🧹 CLEAR LOCAL
  // ============================================================

  Future<void> clearLocalClients() async {
    final db = await DatabaseService().database;
    await db.delete("clients");
  }

  // ============================================================
  // 🛑 DISPOSE
  // ============================================================

  Future<void> dispose() async {
    _isListening = false;

    await _addedSub?.cancel();
    await _changedSub?.cancel();
    await _removedSub?.cancel();

    await useCase.dispose();
  }
}