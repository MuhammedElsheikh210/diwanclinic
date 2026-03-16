class MedicalCenterModel {
  String? key;
  String? name;
  String? address;
  String? phone;
  String? logo;
  String? coverImage;
  double? rating;
  int? numberOfRates;
  int updatedAt;
  bool isDeleted;

  MedicalCenterModel({
    this.key,
    this.name,
    this.address,
    this.phone,
    this.logo,
    this.coverImage,
    this.rating,
    this.numberOfRates,
    int? updatedAt,
    this.isDeleted = false,
  }) : updatedAt = updatedAt ?? DateTime.now().millisecondsSinceEpoch;

  factory MedicalCenterModel.fromJson(Map<String, dynamic> json) {
    int safeInt(dynamic v) =>
        v is int ? v : int.tryParse(v?.toString() ?? '0') ?? 0;

    return MedicalCenterModel(
      key: json['key'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      logo: json['logo'],
      coverImage: json['cover_image'],
      rating: (json['rating'] is int)
          ? (json['rating'] as int).toDouble()
          : (json['rating'] as double?) ?? 0.0,
      numberOfRates: safeInt(json['number_of_rates']),
      updatedAt: safeInt(json['updated_at']),
      isDeleted: json['is_deleted'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'address': address,
      'phone': phone,
      'logo': logo,
      'cover_image': coverImage,
      'rating': rating ?? 0.0,
      'number_of_rates': numberOfRates ?? 0,
      'updated_at': updatedAt,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  MedicalCenterModel copyWith({
    String? key,
    String? name,
    String? address,
    String? phone,
    String? logo,
    String? coverImage,
    double? rating,
    int? numberOfRates,
    int? updatedAt,
    bool? isDeleted,
  }) {
    return MedicalCenterModel(
      key: key ?? this.key,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      logo: logo ?? this.logo,
      coverImage: coverImage ?? this.coverImage,
      rating: rating ?? this.rating,
      numberOfRates: numberOfRates ?? this.numberOfRates,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}