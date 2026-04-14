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

  // ✅ NEW
  final int remoteReservationAbility;

  const DoctorUser({
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
    this.specializationName,
    this.specializeKey,
    this.doctorQualifications,
    this.facebookLink,
    this.instagramLink,
    this.tiktokLink,
    this.totalRate,
    this.numberOfRates,
    this.remoteReservationAbility = 1,
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

    return data;
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  DoctorUser copyWith({
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
    String? specializationName,
    String? specializeKey,
    String? doctorQualifications,
    String? facebookLink,
    String? instagramLink,
    String? tiktokLink,
    double? totalRate,
    int? numberOfRates,
    int? remoteReservationAbility,
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
      name: name ?? this.name,
      address: address ?? this.address,
      password: password ?? this.password,
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
    );
  }
}
