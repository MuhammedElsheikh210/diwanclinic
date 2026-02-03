class PatientModel {
  final String? key;
  final String? uid;
  final String? name;
  final String? phone;
  final String? address;
  final String? code;
  final int? create_at;
  final String? birthday;

  // ✅ إضافات جديدة
  final String? diagnosis;
  final String? allergies; // أمراض/حساسية

  PatientModel({
    this.key,
    this.uid,
    this.birthday,
    this.name,
    this.phone,
    this.address,
    this.create_at,
    this.code,
    this.diagnosis,
    this.allergies,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (key?.isNotEmpty == true) data['key'] = key;
    if (birthday?.isNotEmpty == true) data['birthday'] = birthday;
    if (create_at != null) data['create_at'] = create_at;
    if (uid?.isNotEmpty == true) data['uid'] = uid;
    if (name?.isNotEmpty == true) data['name'] = name;
    if (phone?.isNotEmpty == true) data['phone'] = phone;
    if (address?.isNotEmpty == true) data['address'] = address;
    if (code?.isNotEmpty == true) data['code'] = code;
    if (diagnosis?.isNotEmpty == true) data['diagnosis'] = diagnosis;
    if (allergies?.isNotEmpty == true) data['allergies'] = allergies;
    return data;
  }

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      key: json['key'],
      uid: json['uid'],
      create_at: json['create_at'],
      name: json['name'],
      birthday: json['birthday'],
      phone: json['phone'],
      address: json['address'],
      code: json['code'],
      diagnosis: json['diagnosis'],
      allergies: json['allergies'],
    );
  }

  PatientModel copyWith({
    String? key,
    String? name,
    String? phone,
    String? uid,
    String? address,
    String? birthday,
    int? create_at,
    String? code,
    String? diagnosis,
    String? allergies,
  }) {
    return PatientModel(
      key: key ?? this.key,
      name: name ?? this.name,
      birthday: birthday ?? this.birthday,
      phone: phone ?? this.phone,
      uid: uid ?? this.uid,
      create_at: create_at ?? this.create_at,
      address: address ?? this.address,
      code: code ?? this.code,
      diagnosis: diagnosis ?? this.diagnosis,
      allergies: allergies ?? this.allergies,
    );
  }
}
