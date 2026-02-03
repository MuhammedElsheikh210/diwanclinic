class AssistantModel {
  final String? key;
  final String? doctorKey;
  final String? clinicKey;
  final String? name;
  final String? phone;
  final String? password;

  AssistantModel({
    this.key,
    this.doctorKey,
    this.clinicKey,
    this.name,
    this.phone,
    this.password,
  });

  /// ✅ Convert Model to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (key?.isNotEmpty == true) data['key'] = key;
    if (doctorKey?.isNotEmpty == true) data['doctor_key'] = doctorKey;
    if (clinicKey?.isNotEmpty == true) data['clinicKey'] = clinicKey;
    if (name?.isNotEmpty == true) data['name'] = name;
    if (phone?.isNotEmpty == true) data['phone'] = phone;
    if (password?.isNotEmpty == true) data['password'] = password;
    return data;
  }

  /// ✅ Create Model from JSON
  factory AssistantModel.fromJson(Map<String, dynamic> json) {
    return AssistantModel(
      key: json['key'],
      doctorKey: json['doctor_key'],
      clinicKey: json['clinicKey'],
      name: json['name'],
      phone: json['phone'],
      password: json['password'],
    );
  }

  /// ✅ CopyWith
  AssistantModel copyWith({
    String? key,
    String? doctorKey,
    String? clinicKey,
    String? name,
    String? phone,
    String? password,
  }) {
    return AssistantModel(
      key: key ?? this.key,
      doctorKey: doctorKey ?? this.doctorKey,
      clinicKey: clinicKey ?? this.clinicKey,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      password: password ?? this.password,
    );
  }
}
