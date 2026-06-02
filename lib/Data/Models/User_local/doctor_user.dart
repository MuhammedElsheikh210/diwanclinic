import '../../../index/index_main.dart';

class DoctorUser extends BaseUser {
  final String? specializationName;
  final String? specializeKey;
  final String? doctorQualifications;

  // Social
  final String? facebookLink;
  final String? instagramLink;
  final String? tiktokLink;

  // Rating
  final double? totalRate;
  final int? numberOfRates;

  final int remoteReservationAbility;

  // 💳 Online Payment
  final bool supportsOnlinePay;
  final bool requiresDeposit;
  final String? walletNumber;
  final String? walletHolderName;
  final String? instapayNumber;
  final String? instapayHolderName;
  final String? instapayLink;

  const DoctorUser({
    super.uid,
    super.createdAt,
    super.userType,
    super.isProfileCompleted,
    super.fcmToken,
    super.appVersion,
    super.identifier,
    super.profileImage,
    super.code,
    super.phone,
    super.name,
    super.address,
    super.password,
    super.latitude,
    super.longitude,
    this.specializationName,
    this.specializeKey,
    this.doctorQualifications,
    this.facebookLink,
    this.instagramLink,
    this.tiktokLink,
    this.totalRate,
    this.numberOfRates,
    this.remoteReservationAbility = 1,
    this.supportsOnlinePay = false,
    this.requiresDeposit = false,
    this.walletNumber,
    this.walletHolderName,
    this.instapayNumber,
    this.instapayHolderName,
    this.instapayLink,
  });

  // ============================================================
  // FROM JSON
  // ============================================================

  factory DoctorUser.fromJson(Map<String, dynamic> json) {
    final base = BaseUser.fromJson(json);

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString());
    }

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }

    int parseBoolToInt(dynamic value) {
      if (value is int) return value;
      if (value is bool) return value ? 1 : 0;
      if (value is String) {
        return value == '1' || value.toLowerCase() == 'true' ? 1 : 0;
      }
      return 0;
    }

    return DoctorUser(
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
      specializationName: json['specialization_name'],
      specializeKey: json['specialize_key'],
      doctorQualifications: json['doctorQualifications'],

      facebookLink: json['facebook_link'],
      instagramLink: json['instagram_link'],
      tiktokLink: json['tiktok_link'],

      totalRate: parseDouble(json['total_rate']),
      numberOfRates: parseInt(json['number_of_rates']),

      remoteReservationAbility: parseBoolToInt(
        json['remote_reservation_ability'],
      ),
      supportsOnlinePay: parseBoolToInt(json['supports_online_pay']) == 1,
      requiresDeposit: parseBoolToInt(json['requires_deposit']) == 1,
      walletNumber: json['wallet_number'],
      walletHolderName: json['wallet_holder_name'],
      instapayNumber: json['instapay_number'],
      instapayHolderName: json['instapay_holder_name'],
      instapayLink: json['instapay_link'],
    );
  }

  // ============================================================
  // TO JSON (FIXED 🔥)
  // ============================================================

  @override
  Map<String, dynamic> toJson({bool isUpdate = false}) {
    final data = super.toJson(isUpdate: isUpdate);

    void put(String key, dynamic value) {
      if (value != null) data[key] = value;
    }

    put("specialization_name", specializationName);
    put("specialize_key", specializeKey);
    put("doctorQualifications", doctorQualifications);

    put("facebook_link", facebookLink);
    put("instagram_link", instagramLink);
    put("tiktok_link", tiktokLink);

    data["total_rate"] = totalRate ?? 0.0;
    data["number_of_rates"] = numberOfRates ?? 0;

    data["remote_reservation_ability"] = remoteReservationAbility;

    data["supports_online_pay"] = supportsOnlinePay ? 1 : 0;
    data["requires_deposit"] = requiresDeposit ? 1 : 0;
    put("wallet_number", walletNumber);
    put("wallet_holder_name", walletHolderName);
    put("instapay_number", instapayNumber);
    put("instapay_holder_name", instapayHolderName);
    put("instapay_link", instapayLink);

    return data;
  }

  // ============================================================
  // COPY WITH
  // ============================================================
  @override
  DoctorUser copyWith({
    String? uid,
    int? createdAt,
    UserType? userType,
    bool? isProfileCompleted,
    String? fcmToken,
    String? appVersion,
    String? identifier,
    String? profileImage,
    String? code,
    String? phone,
    String? name,
    String? address,
    String? password,
    double? latitude,
    double? longitude,
    String? specializationName,
    String? specializeKey,
    String? doctorQualifications,
    String? facebookLink,
    String? instagramLink,
    String? tiktokLink,
    double? totalRate,
    int? numberOfRates,
    int? remoteReservationAbility,
    bool? supportsOnlinePay,
    bool? requiresDeposit,
    String? walletNumber,
    String? walletHolderName,
    String? instapayNumber,
    String? instapayHolderName,
    String? instapayLink,
  }) {
    return DoctorUser(
      uid: uid ?? this.uid,
      createdAt: createdAt ?? this.createdAt,
      userType: userType ?? this.userType,
      isProfileCompleted: isProfileCompleted ?? this.isProfileCompleted,
      fcmToken: fcmToken ?? this.fcmToken,
      appVersion: appVersion ?? this.appVersion,
      identifier: identifier ?? this.identifier,
      profileImage: profileImage ?? this.profileImage,
      phone: phone ?? this.phone,
      code: code ?? this.code,
      name: name ?? this.name,
      address: address ?? this.address,
      password: password ?? this.password,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      specializationName: specializationName ?? this.specializationName,
      specializeKey: specializeKey ?? this.specializeKey,
      doctorQualifications: doctorQualifications ?? this.doctorQualifications,
      facebookLink: facebookLink ?? this.facebookLink,
      instagramLink: instagramLink ?? this.instagramLink,
      tiktokLink: tiktokLink ?? this.tiktokLink,
      totalRate: totalRate ?? this.totalRate,
      numberOfRates: numberOfRates ?? this.numberOfRates,
      remoteReservationAbility:
          remoteReservationAbility ?? this.remoteReservationAbility,
      supportsOnlinePay: supportsOnlinePay ?? this.supportsOnlinePay,
      requiresDeposit: requiresDeposit ?? this.requiresDeposit,
      walletNumber: walletNumber ?? this.walletNumber,
      walletHolderName: walletHolderName ?? this.walletHolderName,
      instapayNumber: instapayNumber ?? this.instapayNumber,
      instapayHolderName: instapayHolderName ?? this.instapayHolderName,
      instapayLink: instapayLink ?? this.instapayLink,
    );
  }
}
