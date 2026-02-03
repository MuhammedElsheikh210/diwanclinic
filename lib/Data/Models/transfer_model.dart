class TransferModel {
  final String? key;
  final String? reservationKey;
  final String? url;
  final String? patientKey;
  final String? doctorKey;
  final String? createAt;
  final String? amount;

  TransferModel({
    this.key,
    this.reservationKey,
    this.url,
    this.patientKey,
    this.doctorKey,
    this.createAt,
    this.amount,
  });

  /// ✅ Convert Model to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (key?.isNotEmpty == true) data['key'] = key;
    if (reservationKey?.isNotEmpty == true) {
      data['reservation_key'] = reservationKey;
    }
    if (url?.isNotEmpty == true) data['url'] = url;
    if (patientKey?.isNotEmpty == true) data['patient_key'] = patientKey;
    if (doctorKey?.isNotEmpty == true) data['doctor_key'] = doctorKey;
    if (createAt?.isNotEmpty == true) data['create_at'] = createAt;
    if (amount?.isNotEmpty == true) data['amount'] = amount;
    return data;
  }

  /// ✅ Create Model from JSON
  factory TransferModel.fromJson(Map<String, dynamic> json) {
    return TransferModel(
      key: json['key'],
      reservationKey: json['reservation_key'],
      url: json['url'],
      patientKey: json['patient_key'],
      doctorKey: json['doctor_key'],
      createAt: json['create_at'],
      amount: json['amount'],
    );
  }

  /// ✅ CopyWith
  TransferModel copyWith({
    String? key,
    String? reservationKey,
    String? url,
    String? patientKey,
    String? doctorKey,
    String? createAt,
    String? amount,
  }) {
    return TransferModel(
      key: key ?? this.key,
      reservationKey: reservationKey ?? this.reservationKey,
      url: url ?? this.url,
      patientKey: patientKey ?? this.patientKey,
      doctorKey: doctorKey ?? this.doctorKey,
      createAt: createAt ?? this.createAt,
      amount: amount ?? this.amount,
    );
  }
}
