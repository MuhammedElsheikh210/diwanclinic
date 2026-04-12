import '../../../index/index_main.dart';

class LocalUser {
  final BaseUser user;

  const LocalUser(this.user);

  // ============================================================
  // FACTORY
  // ============================================================

  factory LocalUser.fromMap(Map<String, dynamic> json) {
    final user = UserMapper.fromMap(json);
    return LocalUser(user);
  }

  // ============================================================
  // TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return user.toJson();
  }

  // ============================================================
  // TYPE HELPERS
  // ============================================================

  bool get isDoctor => user is DoctorUser;

  bool get isAssistant => user is AssistantUser;

  DoctorUser? get asDoctor => user is DoctorUser ? user as DoctorUser : null;

  AssistantUser? get asAssistant =>
      user is AssistantUser ? user as AssistantUser : null;

  // ============================================================
  // COMMON FIELDS (FIX ✅)
  // ============================================================

  String? get uid => user.uid;

  String? get name => user.name;

  String? get phone => user.phone;

  String? get fcmToken => user.fcmToken;

  String? get email => user.identifier;

  String? get address => user.address;

  String? get profileImage => user.profileImage;

  bool get hasImage => user.hasImage;

  // ============================================================
  // DOCTOR FIELDS (SAFE ACCESS ✅)
  // ============================================================

  double get totalRate => asDoctor?.totalRate ?? 0.0;

  int get numberOfRates => asDoctor?.numberOfRates ?? 0;

  String? get specializeKey => asDoctor?.specializeKey;

  // ============================================================
  // ASSISTANT FIELDS (optional)
  // ============================================================

  String? get clinicKey => asAssistant?.clinicKey;

  String? get doctorKey => asAssistant?.doctorKey;
}
