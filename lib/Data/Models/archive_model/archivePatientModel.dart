class ArchivePatientModel {
  final String id;           // id السجل نفسه
  final String patientId;    // id المريض
  final String formId;       // id الفورم المستخدم
  final Map<String, dynamic> data; // بيانات الحقول (ديناميك)
  final String createdAt;    // تاريخ الإنشاء

  ArchivePatientModel({
    required this.id,
    required this.patientId,
    required this.formId,
    required this.data,
    required this.createdAt,
  });

  /// ================= FROM JSON =================

  factory ArchivePatientModel.fromJson(
      String id,
      Map<String, dynamic> json,
      ) {
    return ArchivePatientModel(
      id: id,
      patientId: json['patientId'] ?? '',
      formId: json['formId'] ?? '',
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      createdAt: json['createdAt'] ?? '',
    );
  }

  /// ================= TO JSON =================

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'formId': formId,
      'data': data,
      'createdAt': createdAt,
    };
  }
}
