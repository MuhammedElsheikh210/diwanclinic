import '../../../index/index_main.dart';

extension UserRoleX on BaseUser {
  bool get isDoctor => userType == UserType.doctor;

  bool get isAssistant => userType == UserType.assistant;

  bool get isPatient => userType == UserType.patient;
}

class BaseUser {
  final String? uid;
  final int? createdAt;

  final UserType? userType;
  final bool isProfileCompleted;

  final String? fcmToken;
  final String? appVersion;

  final String? email;

  final String? profileImage;
  final String? phone;
  final String? name;
  final String? address;

  // 🚨 TEMP ONLY
  final String? password;

  const BaseUser({
    this.uid,
    this.createdAt,
    this.userType,
    this.isProfileCompleted = false,
    this.fcmToken,
    this.appVersion,
    this.email,
    this.profileImage,
    this.phone,
    this.name,
    this.address,
    this.password, // 👈 added
  });

  // ============================================================
  // FROM JSON
  // ============================================================

  factory BaseUser.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value == '1' || value.toLowerCase() == 'true';
      return false;
    }

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }

    return BaseUser(
      uid: json['uid'] ?? json['token'],
      createdAt: parseInt(json['createdAt']),
      userType: UserTypeExtension.fromString(json['userType']),
      isProfileCompleted: parseBool(json['isCompleteProfile']),
      fcmToken: json['fcm_token'],
      appVersion: json['app_version'],
      email: json['email'] ?? json['identifier'],
      profileImage: json['profile_image'] ?? json['profileImage'],
      phone: json['phone'],
      name: json['name'] ?? json['client_name'],
      address: json['address'],
      password: json['password'],
    );
  }

  // ============================================================
  // TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    void put(String key, dynamic value) {
      if (value != null) data[key] = value;
    }

    put('uid', uid);
    put('createdAt', createdAt);
    put('userType', userType?.name);
    put('isCompleteProfile', isProfileCompleted ? 1 : 0);
    put('fcm_token', fcmToken);
    put('app_version', appVersion);
    put('email', email);
    put('profile_image', profileImage);
    put('phone', phone);
    put('name', name);
    put('address', address);
    put('password', password);

    return data;
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  BaseUser copyWith({
    String? uid,
    int? createdAt,
    UserType? userType,
    bool? isProfileCompleted,
    String? fcmToken,
    String? appVersion,
    String? email,
    String? profileImage,
    String? phone,
    String? name,
    String? address,
    String? password, // 👈 added
  }) {
    return BaseUser(
      uid: uid ?? this.uid,
      createdAt: createdAt ?? this.createdAt,
      userType: userType ?? this.userType,
      isProfileCompleted: isProfileCompleted ?? this.isProfileCompleted,
      fcmToken: fcmToken ?? this.fcmToken,
      appVersion: appVersion ?? this.appVersion,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      address: address ?? this.address,
      password: password ?? this.password,
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  bool get hasImage => profileImage != null && profileImage!.isNotEmpty;

  bool get hasPhone => phone != null && phone!.isNotEmpty;

  bool get hasName => name != null && name!.isNotEmpty;
}
