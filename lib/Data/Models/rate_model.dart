class DoctorReviewModel {
  final String? key;
  final String? doctorId;
  final String? patientId;
  final String? comment;
  final int? rateValue;
  final int? createdAt;
  final String? patientName;
  final String? reserv_id;
  final String? path;           // ✅ NEW FIELD

  DoctorReviewModel({
    this.key,
    this.doctorId,
    this.patientId,
    this.comment,
    this.rateValue,
    this.reserv_id,
    this.createdAt,
    this.patientName,
    this.path,                 // 👈 added
  });

  /// Convert Model to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (key != null && key!.isNotEmpty) data['key'] = key;
    if (doctorId != null && doctorId!.isNotEmpty) data['doctor_id'] = doctorId;
    if (patientId != null && patientId!.isNotEmpty) data['patient_id'] = patientId;
    if (comment != null && comment!.isNotEmpty) data['comment'] = comment;
    if (reserv_id != null && reserv_id!.isNotEmpty) data['reserv_id'] = reserv_id;
    if (rateValue != null) data['rate_value'] = rateValue;
    if (createdAt != null) data['created_at'] = createdAt;
    if (patientName != null && patientName!.isNotEmpty) {
      data['patient_name'] = patientName;
    }
    if (path != null && path!.isNotEmpty) data['path'] = path; // 👈 added

    return data;
  }

  /// Create Model from JSON
  factory DoctorReviewModel.fromJson(Map<String, dynamic> json) {
    return DoctorReviewModel(
      key: json['key'],
      reserv_id: json['reserv_id'],
      doctorId: json['doctor_id'],
      patientId: json['patient_id'],
      comment: json['comment'],
      rateValue: json['rate_value'],
      createdAt: json['created_at'],
      patientName: json['patient_name'],
      path: json['path'], // 👈 added
    );
  }

  /// CopyWith
  DoctorReviewModel copyWith({
    String? key,
    String? doctorId,
    String? patientId,
    String? comment,
    String? reserv_id,
    int? rateValue,
    int? createdAt,
    String? patientName,
    String? path, // 👈 added
  }) {
    return DoctorReviewModel(
      key: key ?? this.key,
      doctorId: doctorId ?? this.doctorId,
      reserv_id: reserv_id ?? this.reserv_id,
      patientId: patientId ?? this.patientId,
      comment: comment ?? this.comment,
      rateValue: rateValue ?? this.rateValue,
      createdAt: createdAt ?? this.createdAt,
      patientName: patientName ?? this.patientName,
      path: path ?? this.path, // 👈 added
    );
  }
}
