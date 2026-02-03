class DoctorSuggestionModel {
  final String? key;
  final String? patientkey;
  final String? doctorName;
  final String? specializeName;
  final String? address;

  DoctorSuggestionModel({
    this.key,
    this.doctorName,
    this.patientkey,
    this.specializeName,
    this.address,
  });

  /// ✅ Convert Model to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (key != null && key!.isNotEmpty) data['key'] = key;
    if (patientkey != null && patientkey!.isNotEmpty)
      data['patientkey'] = patientkey;
    if (doctorName != null && doctorName!.isNotEmpty)
      data['doctor_name'] = doctorName;
    if (specializeName != null && specializeName!.isNotEmpty)
      data['specialize_name'] = specializeName;
    if (address != null && address!.isNotEmpty) data['address'] = address;
    return data;
  }

  /// ✅ Create Model from JSON
  factory DoctorSuggestionModel.fromJson(Map<String, dynamic> json) {
    return DoctorSuggestionModel(
      key: json['key'],
      patientkey: json['patientkey'],
      doctorName: json['doctor_name'],
      specializeName: json['specialize_name'],
      address: json['address'],
    );
  }

  /// ✅ CopyWith
  DoctorSuggestionModel copyWith({
    String? key,
    String? patientkey,
    String? doctorName,
    String? specializeName,
    String? address,
  }) {
    return DoctorSuggestionModel(
      key: key ?? this.key,
      patientkey: patientkey ?? this.patientkey,
      doctorName: doctorName ?? this.doctorName,
      specializeName: specializeName ?? this.specializeName,
      address: address ?? this.address,
    );
  }
}
