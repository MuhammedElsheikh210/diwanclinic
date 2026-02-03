class IncomeModel {
  final String? key;
  final String? doctorKey;
  final String? patientKey;
  final String? assistantKey;
  final double? totalPrescriptionValue; // إجمالي قيمة الروشتة
  final int? prescDiscountPercent; // نسبة الخصم %
  final double? prescDiscountAmount; // قيمة الخصم
  final String? reservationId;
  final int? createdAt;
  final String? clinicKey;

  IncomeModel({
    this.key,
    this.doctorKey,
    this.patientKey,
    this.assistantKey,
    this.totalPrescriptionValue,
    this.prescDiscountPercent,
    this.prescDiscountAmount,
    this.reservationId,
    this.createdAt,
    this.clinicKey,
  });

  /// ✅ Convert Model to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (key != null && key!.isNotEmpty) data['key'] = key;
    if (doctorKey != null && doctorKey!.isNotEmpty)
      data['doctor_key'] = doctorKey;
    if (patientKey != null && patientKey!.isNotEmpty)
      data['patient_key'] = patientKey;
    if (assistantKey != null && assistantKey!.isNotEmpty)
      data['assistant_key'] = assistantKey;
    if (totalPrescriptionValue != null)
      data['total_prescription_value'] = totalPrescriptionValue;
    if (prescDiscountPercent != null)
      data['presc_discount_percent'] = prescDiscountPercent;
    if (prescDiscountAmount != null)
      data['presc_discount_amount'] = prescDiscountAmount;
    if (reservationId != null && reservationId!.isNotEmpty)
      data['reservation_id'] = reservationId;
    if (createdAt != null) data['created_at'] = createdAt;
    if (clinicKey != null && clinicKey!.isNotEmpty)
      data['clinic_key'] = clinicKey;
    return data;
  }

  /// ✅ Create Model from JSON
  factory IncomeModel.fromJson(Map<String, dynamic> json) {
    return IncomeModel(
      key: json['key'],
      doctorKey: json['doctor_key'],
      patientKey: json['patient_key'],
      assistantKey: json['assistant_key'],
      totalPrescriptionValue: (json['total_prescription_value'] != null)
          ? (json['total_prescription_value'] as num).toDouble()
          : null,
      prescDiscountPercent: json['presc_discount_percent'],
      prescDiscountAmount: (json['presc_discount_amount'] != null)
          ? (json['presc_discount_amount'] as num).toDouble()
          : null,
      reservationId: json['reservation_id'],
      createdAt: json['created_at'],
      clinicKey: json['clinic_key'],
    );
  }

  /// ✅ CopyWith
  IncomeModel copyWith({
    String? key,
    String? doctorKey,
    String? patientKey,
    String? assistantKey,
    double? totalPrescriptionValue,
    int? prescDiscountPercent,
    double? prescDiscountAmount,
    String? reservationId,
    int? createdAt,
    String? clinicKey,
  }) {
    return IncomeModel(
      key: key ?? this.key,
      doctorKey: doctorKey ?? this.doctorKey,
      patientKey: patientKey ?? this.patientKey,
      assistantKey: assistantKey ?? this.assistantKey,
      totalPrescriptionValue:
          totalPrescriptionValue ?? this.totalPrescriptionValue,
      prescDiscountPercent: prescDiscountPercent ?? this.prescDiscountPercent,
      prescDiscountAmount: prescDiscountAmount ?? this.prescDiscountAmount,
      reservationId: reservationId ?? this.reservationId,
      createdAt: createdAt ?? this.createdAt,
      clinicKey: clinicKey ?? this.clinicKey,
    );
  }
}
