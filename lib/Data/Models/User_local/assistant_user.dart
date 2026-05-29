import '../../../index/index_main.dart';

class AssistantUser extends BaseUser {
  final String? clinicKey;
  final String? doctorKey;
  final String? doctorName;
  final String? doctorFcmToken;
  final String? transferNumber;
  final bool isInstaPay;

  const AssistantUser({
    super.uid,
    super.createdAt,
    super.userType,
    super.isProfileCompleted,
    super.fcmToken,
    super.appVersion,
    super.identifier,
    super.profileImage,
    super.phone,
    super.name,
    super.address,
    super.password,
    super.code,
    super.latitude,
    super.longitude,
    this.clinicKey,
    this.doctorKey,
    this.doctorName,
    this.doctorFcmToken,
    this.transferNumber,
    this.isInstaPay = false,
  });

  // ============================================================
  // FROM JSON
  // ============================================================

  factory AssistantUser.fromJson(Map<String, dynamic> json) {
    final base = BaseUser.fromJson(json);

    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) {
        return value == '1' || value.toLowerCase() == 'true';
      }
      return false;
    }

    return AssistantUser(
      uid: base.uid,
      createdAt: base.createdAt,
      userType: base.userType,
      isProfileCompleted: base.isProfileCompleted,
      fcmToken: base.fcmToken,
      appVersion: base.appVersion,
      identifier: base.identifier,
      profileImage: base.profileImage,
      phone: base.phone,
      name: base.name,
      address: base.address,
      password: base.password,
      code: base.code,
      latitude: base.latitude,
      longitude: base.longitude,

      clinicKey: json['clinic_key'],
      doctorKey: json['doctor_key'],
      doctorName: json['doctor_name'],
      doctorFcmToken: json['doctor_fcm_token'],
      transferNumber: json['transfer_number'],
      isInstaPay: parseBool(json['is_insta_pay']),
    );
  }

  // ============================================================
  // TO JSON
  // ============================================================

  @override
  Map<String, dynamic> toJson({bool isUpdate = false}) {
    final data = super.toJson(isUpdate: isUpdate);

    void put(String key, dynamic value) {
      if (value != null) data[key] = value;
    }

    /// required
    put('doctor_key', doctorKey);

    /// doctor data
    put('doctor_name', doctorName);
    put('doctor_fcm_token', doctorFcmToken);

    /// optional
    put('clinic_key', clinicKey);
    put('transfer_number', transferNumber);

    /// bool → int
    data['is_insta_pay'] = isInstaPay ? 1 : 0;

    return data;
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  @override
  AssistantUser copyWith({
    String? uid,
    int? createdAt,
    UserType? userType,
    bool? isProfileCompleted,
    String? fcmToken,
    String? appVersion,
    String? identifier,
    String? profileImage,
    String? phone,
    String? name,
    String? address,
    String? password,
    String? code,
    double? latitude,
    double? longitude,
    String? clinicKey,
    String? doctorKey,
    String? doctorName,
    String? doctorFcmToken,
    String? transferNumber,
    bool? isInstaPay,
  }) {
    return AssistantUser(
      uid: uid ?? this.uid,
      createdAt: createdAt ?? this.createdAt,
      userType: userType ?? this.userType,
      isProfileCompleted: isProfileCompleted ?? this.isProfileCompleted,
      fcmToken: fcmToken ?? this.fcmToken,
      appVersion: appVersion ?? this.appVersion,
      identifier: identifier ?? this.identifier,
      profileImage: profileImage ?? this.profileImage,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      address: address ?? this.address,
      password: password ?? this.password,
      code: code ?? this.code,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,

      clinicKey: clinicKey ?? this.clinicKey,
      doctorKey: doctorKey ?? this.doctorKey,
      doctorName: doctorName ?? this.doctorName,
      doctorFcmToken: doctorFcmToken ?? this.doctorFcmToken,
      transferNumber: transferNumber ?? this.transferNumber,
      isInstaPay: isInstaPay ?? this.isInstaPay,
    );
  }
}