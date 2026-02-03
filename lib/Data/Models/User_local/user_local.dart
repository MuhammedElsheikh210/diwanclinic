import '../../../index/index_main.dart';

// 🔹 LocalUser model
class LocalUser {
  String? uid;
  String? key;
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
  String? doctorName;
  String? salesKey;
  String? clinicKey;
  String? code;

  // 🔹 Social links
  String? facebookLink;
  String? instagramLink;
  String? tiktokLink;

  // 🔹 Payout / transfers
  String? transferNumber;
  int? isInstaPay;
  int? isElectronicWallet;

  // 🔹 NEW FIELDS
  int? show_file_number;
  int? file_number;
  int? remote_reservation_ability;

  // 🔹 Notification token
  String? fcmToken;

  // 🔹 Rating fields
  double? totalRate;
  int? numberOfRates;

  LocalUser({
    this.uid,
    this.key,
    this.userType,
    this.isCompleteProfile,
    this.identifier,
    this.password,
    this.image,
    this.profileImage,
    this.coverImage,
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
  });

  // ─────────────────────────────────────────────
  // 🔹 From JSON
  // ─────────────────────────────────────────────
  factory LocalUser.fromJson(Map<String, dynamic> json) {
    return LocalUser(
      uid: json['token'],
      key: json['key'],
      specialize_key: json['specialize_key'],
      specializationName: json['specialization_name'],
      phone: json['phone'],
      whatsAppPhone: json['whats_app_phone'],
      image: json['image'],
      profileImage: json['profile_image'] ?? json['profileImage'],
      coverImage: json['cover_image'] ?? json['coverImage'],
      name: json['client_name'] ?? json['name'],
      address: json['address'],
      createAt: json['createAt'],
      password: json['password'],
      identifier: json['identifier'],
      userType: UserTypeExtension.fromString(json['userType']),
      doctorKey: json['doctor_key'],
      doctorName: json['doctor_name'],
      salesKey: json['sales_key'],
      clinicKey: json['clinic_key'],
      code: json['code'],
      transferNumber: json['transfer_number'],
      isInstaPay: json['is_insta_pay'],
      isElectronicWallet: json['is_electronic_wallet'],

      show_file_number: json['show_file_number'],
      file_number: json['file_number'],
      remote_reservation_ability: json['remote_reservation_ability'],

      fcmToken: json['fcm_token'],

      facebookLink: json['facebook_link'],
      instagramLink: json['instagram_link'],
      tiktokLink: json['tiktok_link'],

      totalRate: (json['total_rate'] is int)
          ? (json['total_rate'] as int).toDouble()
          : (json['total_rate'] as double?) ?? 0.0,

      numberOfRates: json['number_of_rates'] is int
          ? json['number_of_rates']
          : int.tryParse(json['number_of_rates']?.toString() ?? '0'),
    );
  }

  // ─────────────────────────────────────────────
  // 🔹 To JSON
  // ─────────────────────────────────────────────
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (uid != null) data['token'] = uid;
    if (key != null) data['key'] = key;
    if (specialize_key != null) data['specialize_key'] = specialize_key;
    if (specializationName != null) data['specialization_name'] = specializationName;

    if (image != null) data['image'] = image;
    if (profileImage != null) data['profile_image'] = profileImage;
    if (coverImage != null) data['cover_image'] = coverImage;

    if (phone != null) data['phone'] = phone;
    if (whatsAppPhone != null) data['whats_app_phone'] = whatsAppPhone;
    if (name != null) data['client_name'] = name;
    if (address != null) data['address'] = address;
    if (isCompleteProfile != null) data['isCompleteProfile'] = isCompleteProfile;
    if (createAt != null) data['createAt'] = createAt;
    if (password != null) data['password'] = password;
    if (identifier != null) data['identifier'] = identifier;
    if (userType != null) data['userType'] = userType!.name;

    if (doctorKey != null) data['doctor_key'] = doctorKey;
    if (doctorName != null) data['doctor_name'] = doctorName;
    if (salesKey != null) data['sales_key'] = salesKey;
    if (clinicKey != null) data['clinic_key'] = clinicKey;
    if (code != null) data['code'] = code;

    if (transferNumber != null) data['transfer_number'] = transferNumber;
    if (isInstaPay != null) data['is_insta_pay'] = isInstaPay;
    if (isElectronicWallet != null) data['is_electronic_wallet'] = isElectronicWallet;

    if (show_file_number != null) data['show_file_number'] = show_file_number;
    if (file_number != null) data['file_number'] = file_number;
    if (remote_reservation_ability != null) {
      data['remote_reservation_ability'] = remote_reservation_ability;
    }

    if (fcmToken != null) data['fcm_token'] = fcmToken;

    if (facebookLink != null) data['facebook_link'] = facebookLink;
    if (instagramLink != null) data['instagram_link'] = instagramLink;
    if (tiktokLink != null) data['tiktok_link'] = tiktokLink;

    if (totalRate != null) data['total_rate'] = totalRate;
    if (numberOfRates != null) data['number_of_rates'] = numberOfRates;

    return data;
  }

  // ─────────────────────────────────────────────
  // 🔹 Copy With
  // ─────────────────────────────────────────────
  LocalUser copyWith({
    String? uid,
    String? key,
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
    String? facebookLink,
    String? instagramLink,
    String? tiktokLink,
    double? totalRate,
    int? numberOfRates,
  }) {
    return LocalUser(
      uid: uid ?? this.uid,
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
      facebookLink: facebookLink ?? this.facebookLink,
      instagramLink: instagramLink ?? this.instagramLink,
      tiktokLink: tiktokLink ?? this.tiktokLink,
      totalRate: totalRate ?? this.totalRate,
      numberOfRates: numberOfRates ?? this.numberOfRates,
    );
  }
}
