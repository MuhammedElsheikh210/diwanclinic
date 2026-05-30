import '../../../index/index_main.dart';

class PharmacyUser extends BaseUser {
  final String? walletNumber;
  final String? instapayNumber;
  final String? instapayLink;

  /// Group identifier — same for all staff of one pharmacy.
  /// For the primary (owner) account: pharmacyId == uid.
  /// For staff accounts: pharmacyId == owner.uid.
  final String? pharmacyId;

  const PharmacyUser({
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
    this.walletNumber,
    this.instapayNumber,
    this.instapayLink,
    this.pharmacyId,
  });

  factory PharmacyUser.fromJson(Map<String, dynamic> json) {
    final base = BaseUser.fromJson(json);
    return PharmacyUser(
      uid: base.uid,
      createdAt: base.createdAt,
      userType: base.userType,
      isProfileCompleted: base.isProfileCompleted,
      fcmToken: base.fcmToken,
      appVersion: base.appVersion,
      identifier: base.identifier,
      profileImage: base.profileImage,
      code: base.code,
      phone: base.phone,
      name: base.name,
      address: base.address,
      password: base.password,
      latitude: base.latitude,
      longitude: base.longitude,
      walletNumber: json['wallet_number'],
      instapayNumber: json['instapay_number'],
      instapayLink: json['instapay_link'],
      pharmacyId: json['pharmacy_id'],
    );
  }

  @override
  Map<String, dynamic> toJson({bool isUpdate = false}) {
    final data = super.toJson(isUpdate: isUpdate);
    void put(String key, dynamic value) {
      if (value != null) data[key] = value;
    }

    put('wallet_number', walletNumber);
    put('instapay_number', instapayNumber);
    put('instapay_link', instapayLink);
    put('pharmacy_id', pharmacyId);

    return data;
  }

  PharmacyUser copyWithPharmacy({
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
    String? code,
    double? latitude,
    double? longitude,
    String? password,
    String? walletNumber,
    String? instapayNumber,
    String? instapayLink,
    String? pharmacyId,
  }) {
    return PharmacyUser(
      uid: uid ?? this.uid,
      createdAt: createdAt ?? this.createdAt,
      userType: userType ?? this.userType,
      isProfileCompleted: isProfileCompleted ?? this.isProfileCompleted,
      fcmToken: fcmToken ?? this.fcmToken,
      appVersion: appVersion ?? this.appVersion,
      identifier: identifier ?? this.identifier,
      profileImage: profileImage ?? this.profileImage,
      code: code ?? this.code,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      address: address ?? this.address,
      password: password ?? this.password,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      walletNumber: walletNumber ?? this.walletNumber,
      instapayNumber: instapayNumber ?? this.instapayNumber,
      instapayLink: instapayLink ?? this.instapayLink,
      pharmacyId: pharmacyId ?? this.pharmacyId,
    );
  }

  bool get hasWallet => walletNumber != null && walletNumber!.isNotEmpty;
  bool get hasInstapay =>
      (instapayNumber != null && instapayNumber!.isNotEmpty) ||
      (instapayLink != null && instapayLink!.isNotEmpty);
}
