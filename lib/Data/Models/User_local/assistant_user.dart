import '../../../index/index_main.dart';

class AssistantUser extends BaseUser {
  final String? clinicKey;
  final String? doctorKey;
  final String? transferNumber;
  final bool isInstaPay;

  const AssistantUser({
    super.uid,
    super.createdAt,
    super.userType,
    super.isProfileCompleted,
    super.fcmToken,
    super.appVersion,
    super.email,
    super.profileImage,
    super.phone,
    super.name,
    super.address,
    super.password,

    this.clinicKey,
    this.doctorKey,
    this.transferNumber,
    this.isInstaPay = false,
  });

  factory AssistantUser.fromJson(Map<String, dynamic> json) {
    final base = BaseUser.fromJson(json);

    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value == '1';
      return false;
    }

    return AssistantUser(
      uid: base.uid,
      createdAt: base.createdAt,
      userType: base.userType,
      isProfileCompleted: base.isProfileCompleted,
      fcmToken: base.fcmToken,
      appVersion: base.appVersion,
      email: base.email,
      profileImage: base.profileImage,
      phone: base.phone,
      name: base.name,
      address: base.address,
      password: base.password,

      clinicKey: json['clinic_key'],
      doctorKey: json['doctor_key'],
      transferNumber: json['transfer_number'],
      isInstaPay: parseBool(json['is_insta_pay']),
    );
  }
}
