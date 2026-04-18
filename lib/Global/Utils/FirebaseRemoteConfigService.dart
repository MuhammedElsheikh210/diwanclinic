import 'dart:io';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../Presentation/screens/forceudpate/force_update_local.dart';
import '../../index/index_main.dart';

class FirebaseRemoteConfigService {
  FirebaseRemoteConfigService._internal()
    : _remoteConfig = FirebaseRemoteConfig.instance;

  static final FirebaseRemoteConfigService _instance =
      FirebaseRemoteConfigService._internal();

  factory FirebaseRemoteConfigService() => _instance;

  final FirebaseRemoteConfig _remoteConfig;

  // ─────────────────────────────────────────────
  // Local
  // ─────────────────────────────────────────────
  late int _localBuild;

  // ─────────────────────────────────────────────
  // Remote
  // ─────────────────────────────────────────────
  late int _remoteBuild;
  late bool _forceEnabled;
  late List<String> _forceRoles;

  // ─────────────────────────────────────────────
  // Keys (MATCH FIREBASE EXACTLY)
  // ─────────────────────────────────────────────
  String get _buildKey =>
      Platform.isAndroid ? 'android_build_number' : 'ios_build_number';

  String get _forceEnabledKey =>
      Platform.isAndroid
          ? 'android_force_update_enabled'
          : 'ios_force_update_enabled';

  String get _forceRolesKey =>
      Platform.isAndroid
          ? 'android_force_update_roles'
          : 'ios_force_update_roles';

  // ─────────────────────────────────────────────
  // Public API
  // ─────────────────────────────────────────────
  Future<void> checkForceUpdate() async {
    await _setupRemoteConfig();
    await _loadLocalBuild();
    _loadRemoteValues();

    final bool force = _shouldForceUpdate();
    await _save(force);
  }

  // ─────────────────────────────────────────────
  // Setup
  // ─────────────────────────────────────────────
  Future<void> _setupRemoteConfig() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 15),
        minimumFetchInterval: const Duration(seconds: 5),
      ),
    );
    await _remoteConfig.fetchAndActivate();
  }

  // ─────────────────────────────────────────────
  // Loaders
  // ─────────────────────────────────────────────
  Future<void> _loadLocalBuild() async {
    final info = await PackageInfo.fromPlatform();
    _localBuild = int.tryParse(info.buildNumber) ?? 0;

  }

  void _loadRemoteValues() {
    _remoteBuild = _remoteConfig.getInt(_buildKey);
    _forceEnabled = _remoteConfig.getBool(_forceEnabledKey);

    final rolesString = _remoteConfig.getString(_forceRolesKey);
    _forceRoles =
        rolesString
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();


  }

  // ─────────────────────────────────────────────
  // Decision Logic (THE IMPORTANT PART)
  // ─────────────────────────────────────────────
  bool _shouldForceUpdate() {
    // ---------------------------------------------------------
    // 🚫 Feature disabled
    // ---------------------------------------------------------
    if (!_forceEnabled) return false;

    // ---------------------------------------------------------
    // ✅ Already up to date
    // ---------------------------------------------------------
    if (_localBuild >= _remoteBuild) return false;

    // ---------------------------------------------------------
    // 🧠 Get current user
    // ---------------------------------------------------------
    final user = Get.find<UserSession>().user?.user;

    if (user == null || user.userType == null) return false;

    final userType = user.userType!;

    // ---------------------------------------------------------
    // 🎯 Role-based logic (optional custom rules)
    // ---------------------------------------------------------

    if (user is DoctorUser) {
      // لو عايز تعامل خاص بالدكتور
      // return true; // مثال
    }

    // ---------------------------------------------------------
    // 🔥 Force update for allowed roles
    // ---------------------------------------------------------
    return _forceRoles.contains(userType);
  }

  // ─────────────────────────────────────────────
  // Save result locally
  // ─────────────────────────────────────────────
  Future<void> _save(bool force) async {
    await ForceUdpate(forceUpdate: force).saveOnBoardLocal();
  }


}
