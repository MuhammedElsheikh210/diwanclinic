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
    super.email,
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

    this.remoteReservationAbility = 0, // ✅ default
  });

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
      if (value is String) return value == '1' ? 1 : 0;
      return 0;
    }

    return DoctorUser(
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

      specializationName: json['specialization_name'],
      specializeKey: json['specialize_key'],
      doctorQualifications: json['doctorQualifications'],

      facebookLink: json['facebook_link'],
      instagramLink: json['instagram_link'],
      tiktokLink: json['tiktok_link'],

      totalRate: parseDouble(json['total_rate']),
      numberOfRates: parseInt(json['number_of_rates']),

      // ✅ NEW
      remoteReservationAbility:
      parseBoolToInt(json['remote_reservation_ability']),
    );
  }
}