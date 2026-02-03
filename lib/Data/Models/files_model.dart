class FilesModel {
  final String? key;
  final String? title;
  final String? url;
  final String? patientKey;
  final String? doctorKey;
  final String? reservationKey;
  final String? createAt;
  final String? type; // [روشتة ، تحليل ، اشعة]

  FilesModel({
    this.key,
    this.title,
    this.url,
    this.patientKey,
    this.doctorKey,
    this.reservationKey,
    this.createAt,
    this.type,
  });

  /// ✅ Convert Model to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (key?.isNotEmpty == true) data['key'] = key;
    if (title?.isNotEmpty == true) data['title'] = title;
    if (url?.isNotEmpty == true) data['url'] = url;
    if (patientKey?.isNotEmpty == true) data['patient_key'] = patientKey;
    if (doctorKey?.isNotEmpty == true) data['doctor_key'] = doctorKey;
    if (reservationKey?.isNotEmpty == true) {
      data['reservation_key'] = reservationKey;
    }
    if (createAt?.isNotEmpty == true) data['create_at'] = createAt;
    if (type?.isNotEmpty == true) data['type'] = type;
    return data;
  }

  /// ✅ Create Model from JSON
  factory FilesModel.fromJson(Map<String, dynamic> json) {
    return FilesModel(
      key: json['key'],
      title: json['title'],
      url: json['url'],
      patientKey: json['patient_key'],
      doctorKey: json['doctor_key'],
      reservationKey: json['reservation_key'],
      createAt: json['create_at'],
      type: json['type'],
    );
  }

  /// ✅ CopyWith
  FilesModel copyWith({
    String? key,
    String? title,
    String? url,
    String? patientKey,
    String? doctorKey,
    String? reservationKey,
    String? createAt,
    String? type,
  }) {
    return FilesModel(
      key: key ?? this.key,
      title: title ?? this.title,
      url: url ?? this.url,
      patientKey: patientKey ?? this.patientKey,
      doctorKey: doctorKey ?? this.doctorKey,
      reservationKey: reservationKey ?? this.reservationKey,
      createAt: createAt ?? this.createAt,
      type: type ?? this.type,
    );
  }
}
