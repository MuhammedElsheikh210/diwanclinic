import '../../../index/index_main.dart';

class LocalUser {
  String? uid;
  String? key;
  String? medicalCenterKey;
  UserType? userType;
  int? isCompleteProfile;
  String? identifier;
  String? password;
  String? image;
  String? profileImage;
  String? coverImage;
  String? phone;
  String? specialize_key;
  String? specializationName;
  String? whatsAppPhone;
  String? name;
  String? address;
  int? createAt;
  String? doctorKey;
  String? doctorKey_fromAdmin;
  String? doctorName;
  String? doctorQualifications;
  String? salesKey;
  String? clinicKey;
  String? code;

  // Social
  String? facebookLink;
  String? instagramLink;
  String? tiktokLink;

  // Transfers
  String? transferNumber;
  int? isInstaPay;
  int? isElectronicWallet;

  // Extra
  int? show_file_number;
  int? file_number;
  int? remote_reservation_ability;

  // Notifications
  String? fcmToken;

  // Rating
  double? totalRate;
  int? numberOfRates;

  // Sync
  int updatedAt;
  int? serverUpdatedAt;
  bool isDeleted;

  LocalUser({
    this.uid,
    this.doctorKey_fromAdmin,
    this.key,
    this.userType,
    this.isCompleteProfile,
    this.identifier,
    this.password,
    this.image,
    this.doctorQualifications,
    this.profileImage,
    this.coverImage,
    this.medicalCenterKey,
    this.phone,
    this.specialize_key,
    this.specializationName,
    this.whatsAppPhone,
    this.name,
    this.address,
    this.createAt,
    this.doctorKey,
    this.doctorName,
    this.salesKey,
    this.clinicKey,
    this.code,
    this.transferNumber,
    this.isInstaPay,
    this.isElectronicWallet,
    this.show_file_number,
    this.file_number,
    this.remote_reservation_ability,
    this.fcmToken,
    this.totalRate,
    this.numberOfRates,
    this.facebookLink,
    this.instagramLink,
    this.tiktokLink,
    int? updatedAt,
    this.serverUpdatedAt,
    this.isDeleted = false,
  }) : updatedAt = updatedAt ?? DateTime.now().millisecondsSinceEpoch;

  // ============================================================
  // FROM JSON
  // ============================================================

  factory LocalUser.fromJson(Map<String, dynamic> json) {
    int safeInt(dynamic v) =>
        v is int ? v : int.tryParse(v?.toString() ?? '0') ?? 0;

    return LocalUser(
      uid: json['token'],
      doctorKey_fromAdmin: json['doctorKey_fromAdmin'],
      medicalCenterKey: json['medicalCenterKey'],
      key: json['key'],
      doctorQualifications: json['doctorQualifications'],
      specialize_key: json['specialize_key'],
      specializationName: json['specialization_name'],
      phone: json['phone'],
      whatsAppPhone: json['whats_app_phone'],
      image: json['image'],
      profileImage: json['profile_image'] ?? json['profileImage'],
      coverImage: json['cover_image'] ?? json['coverImage'],
      name: json['client_name'] ?? json['name'],
      address: json['address'],
      createAt: safeInt(json['createAt']),
      password: json['password'],
      identifier: json['identifier'],
      userType: UserTypeExtension.fromString(json['userType']),
      doctorKey: json['doctor_key'],
      doctorName: json['doctor_name'],
      salesKey: json['sales_key'],
      clinicKey: json['clinic_key'],
      code: json['code'],
      transferNumber: json['transfer_number'],
      isInstaPay: safeInt(json['is_insta_pay']),
      isElectronicWallet: safeInt(json['is_electronic_wallet']),
      show_file_number: safeInt(json['show_file_number']),
      file_number: safeInt(json['file_number']),
      remote_reservation_ability: safeInt(json['remote_reservation_ability']),
      fcmToken: json['fcm_token'],
      facebookLink: json['facebook_link'],
      instagramLink: json['instagram_link'],
      tiktokLink: json['tiktok_link'],
      totalRate:
          (json['total_rate'] is int)
              ? (json['total_rate'] as int).toDouble()
              : (json['total_rate'] as double?) ?? 0.0,
      numberOfRates: safeInt(json['number_of_rates']),
      updatedAt: safeInt(json['updated_at']),
      serverUpdatedAt: json['server_updated_at'],
      isDeleted: json['is_deleted'] == 1,
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

    put('token', uid);
    put('doctorKey_fromAdmin', doctorKey_fromAdmin);
    put('medicalCenterKey', medicalCenterKey);
    put('key', key);
    put('doctorQualifications', doctorQualifications);
    put('specialize_key', specialize_key);
    put('specialization_name', specializationName);
    put('image', image);
    put('profile_image', profileImage);
    put('cover_image', coverImage);
    put('phone', phone);
    put('whats_app_phone', whatsAppPhone);
    put('client_name', name);
    put('address', address);
    put('isCompleteProfile', isCompleteProfile);
    put('createAt', createAt);
    put('password', password);
    put('identifier', identifier);
    put('userType', userType?.name);
    put('doctor_key', doctorKey);
    put('doctor_name', doctorName);
    put('sales_key', salesKey);
    put('clinic_key', clinicKey);
    put('code', code);
    put('transfer_number', transferNumber);
    put('is_insta_pay', isInstaPay);
    put('is_electronic_wallet', isElectronicWallet);
    put('show_file_number', show_file_number);
    put('file_number', file_number);
    put('remote_reservation_ability', remote_reservation_ability);
    put('fcm_token', fcmToken);
    put('facebook_link', facebookLink);
    put('instagram_link', instagramLink);
    put('tiktok_link', tiktokLink);
    put('total_rate', totalRate);
    put('number_of_rates', numberOfRates);

    put('updated_at', updatedAt);
    put('server_updated_at', serverUpdatedAt);
    put('is_deleted', isDeleted ? 1 : 0);

    return data;
  }

  // ============================================================
  // COPY WITH (FULL)
  // ============================================================

  LocalUser copyWith({
    String? uid,
    String? doctorKey_fromAdmin,
    String? key,
    String? medicalCenterKey,
    UserType? userType,
    int? isCompleteProfile,
    String? identifier,
    String? password,
    String? image,
    String? profileImage,
    String? coverImage,
    String? phone,
    String? specialize_key,
    String? specializationName,
    String? whatsAppPhone,
    String? name,
    String? address,
    int? createAt,
    String? doctorKey,
    String? doctorName,
    String? doctorQualifications,
    String? salesKey,
    String? clinicKey,
    String? code,
    String? transferNumber,
    int? isInstaPay,
    int? isElectronicWallet,
    int? show_file_number,
    int? file_number,
    int? remote_reservation_ability,
    String? fcmToken,
    double? totalRate,
    int? numberOfRates,
    String? facebookLink,
    String? instagramLink,
    String? tiktokLink,
    int? updatedAt,
    int? serverUpdatedAt,
    bool? isDeleted,
  }) {
    return LocalUser(
      uid: uid ?? this.uid,
      doctorKey_fromAdmin: doctorKey_fromAdmin ?? this.doctorKey_fromAdmin,
      medicalCenterKey: medicalCenterKey ?? this.medicalCenterKey,
      key: key ?? this.key,
      userType: userType ?? this.userType,
      isCompleteProfile: isCompleteProfile ?? this.isCompleteProfile,
      identifier: identifier ?? this.identifier,
      password: password ?? this.password,
      image: image ?? this.image,
      profileImage: profileImage ?? this.profileImage,
      coverImage: coverImage ?? this.coverImage,
      phone: phone ?? this.phone,
      specialize_key: specialize_key ?? this.specialize_key,
      specializationName: specializationName ?? this.specializationName,
      whatsAppPhone: whatsAppPhone ?? this.whatsAppPhone,
      name: name ?? this.name,
      address: address ?? this.address,
      createAt: createAt ?? this.createAt,
      doctorKey: doctorKey ?? this.doctorKey,
      doctorName: doctorName ?? this.doctorName,
      doctorQualifications: doctorQualifications ?? this.doctorQualifications,
      salesKey: salesKey ?? this.salesKey,
      clinicKey: clinicKey ?? this.clinicKey,
      code: code ?? this.code,
      transferNumber: transferNumber ?? this.transferNumber,
      isInstaPay: isInstaPay ?? this.isInstaPay,
      isElectronicWallet: isElectronicWallet ?? this.isElectronicWallet,
      show_file_number: show_file_number ?? this.show_file_number,
      file_number: file_number ?? this.file_number,
      remote_reservation_ability:
          remote_reservation_ability ?? this.remote_reservation_ability,
      fcmToken: fcmToken ?? this.fcmToken,
      totalRate: totalRate ?? this.totalRate,
      numberOfRates: numberOfRates ?? this.numberOfRates,
      facebookLink: facebookLink ?? this.facebookLink,
      instagramLink: instagramLink ?? this.instagramLink,
      tiktokLink: tiktokLink ?? this.tiktokLink,
      updatedAt: updatedAt ?? this.updatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
