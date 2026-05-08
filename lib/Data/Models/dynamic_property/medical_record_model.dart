import '../../../index/index_main.dart';

class MedicalRecordModel {
  final String? key;

  final String? patientKey;
  final String? doctorKey;
  final String? reservationKey;

  /// optional
  final String? categoryKey;

  /// optional
  final String? categoryName;

  final String? createAt;

  /// ✅ Follow-up / revisit date
  final String? revisitDate;

  /// active - archived - deleted
  final String? status;

  /// General notes
  final String? notes;

  /// Images only
  final List<String>? photos;

  /// Dynamic properties
  final List<MedicalRecordPropertyModel>? properties;

  MedicalRecordModel({
    this.key,
    this.patientKey,
    this.doctorKey,
    this.reservationKey,
    this.categoryKey,
    this.categoryName,
    this.createAt,
    this.revisitDate,
    this.status,
    this.notes,
    this.photos,
    this.properties,
  });

  /// ✅ Convert Model to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (key?.isNotEmpty == true) {
      data['key'] = key;
    }

    if (patientKey?.isNotEmpty == true) {
      data['patient_key'] = patientKey;
    }

    if (doctorKey?.isNotEmpty == true) {
      data['doctor_key'] = doctorKey;
    }

    if (reservationKey?.isNotEmpty == true) {
      data['reservation_key'] = reservationKey;
    }

    if (categoryKey?.isNotEmpty == true) {
      data['category_key'] = categoryKey;
    }

    if (categoryName?.isNotEmpty == true) {
      data['category_name'] = categoryName;
    }

    if (createAt?.isNotEmpty == true) {
      data['create_at'] = createAt;
    }

    /// ✅ revisit date
    if (revisitDate?.isNotEmpty == true) {
      data['revisit_date'] = revisitDate;
    }

    if (status?.isNotEmpty == true) {
      data['status'] = status;
    }

    if (notes?.isNotEmpty == true) {
      data['notes'] = notes;
    }

    if (photos != null) {
      data['photos'] = photos;
    }

    if (properties != null) {
      data['properties'] = properties!.map((e) => e.toJson()).toList();
    }

    return data;
  }

  /// ✅ Create Model from JSON
  factory MedicalRecordModel.fromJson(Map<String, dynamic> json) {
    return MedicalRecordModel(
      key: json['key'],

      patientKey: json['patient_key'],

      doctorKey: json['doctor_key'],

      reservationKey: json['reservation_key'],

      categoryKey: json['category_key'],

      categoryName: json['category_name'],

      createAt: json['create_at'],

      /// ✅ revisit date
      revisitDate: json['revisit_date'],

      status: json['status'],

      notes: json['notes'],

      photos: json['photos'] != null ? List<String>.from(json['photos']) : [],

      properties:
          json['properties'] != null
              ? List<MedicalRecordPropertyModel>.from(
                json['properties'].map(
                  (x) => MedicalRecordPropertyModel.fromJson(x),
                ),
              )
              : [],
    );
  }

  /// ✅ CopyWith
  MedicalRecordModel copyWith({
    String? key,
    String? patientKey,
    String? doctorKey,
    String? reservationKey,
    String? categoryKey,
    String? categoryName,
    String? createAt,
    String? revisitDate,
    String? status,
    String? notes,
    List<String>? photos,
    List<MedicalRecordPropertyModel>? properties,
  }) {
    return MedicalRecordModel(
      key: key ?? this.key,

      patientKey: patientKey ?? this.patientKey,

      doctorKey: doctorKey ?? this.doctorKey,

      reservationKey: reservationKey ?? this.reservationKey,

      categoryKey: categoryKey ?? this.categoryKey,

      categoryName: categoryName ?? this.categoryName,

      createAt: createAt ?? this.createAt,

      /// ✅ revisit date
      revisitDate: revisitDate ?? this.revisitDate,

      status: status ?? this.status,

      notes: notes ?? this.notes,

      photos: photos ?? this.photos,

      properties: properties ?? this.properties,
    );
  }
}
