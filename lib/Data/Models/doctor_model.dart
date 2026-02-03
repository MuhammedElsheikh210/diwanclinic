class DoctorModel {
  final String? key;
  final String? name;
  final String? image;
  final String? fees;
  final String? specialistKey;
  final String? bio;
  final String? password;
  final bool? isCompleteProfile;

  DoctorModel({
    this.key,
    this.name,
    this.image,
    this.fees,
    this.specialistKey,
    this.bio,
    this.password,
    this.isCompleteProfile,
  });

  /// ✅ Convert Model to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (key != null && key!.isNotEmpty) data['key'] = key;
    if (name != null && name!.isNotEmpty) data['name'] = name;
    if (image != null && image!.isNotEmpty) data['image'] = image;
    if (fees != null && fees!.isNotEmpty) data['fees'] = fees;
    if (specialistKey != null && specialistKey!.isNotEmpty) {
      data['specialist_key'] = specialistKey;
    }
    if (bio != null && bio!.isNotEmpty) data['bio'] = bio;
    if (password != null && password!.isNotEmpty) {
      data['password'] = password;
    }
    if (isCompleteProfile != null) {
      data['is_complete_profile'] = isCompleteProfile;
    }
    return data;
  }

  /// ✅ Create Model from JSON
  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      key: json['key'],
      name: json['name'],
      image: json['image'],
      fees: json['fees'],
      specialistKey: json['specialist_key'],
      bio: json['bio'],
      password: json['password'],
      isCompleteProfile: json['is_complete_profile'],
    );
  }

  /// ✅ CopyWith
  DoctorModel copyWith({
    String? key,
    String? name,
    String? image,
    String? fees,
    String? specialistKey,
    String? bio,
    String? password,
    bool? isCompleteProfile,
  }) {
    return DoctorModel(
      key: key ?? this.key,
      name: name ?? this.name,
      image: image ?? this.image,
      fees: fees ?? this.fees,
      specialistKey: specialistKey ?? this.specialistKey,
      bio: bio ?? this.bio,
      password: password ?? this.password,
      isCompleteProfile: isCompleteProfile ?? this.isCompleteProfile,
    );
  }
}
