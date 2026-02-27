import 'dart:convert';

class DoctorListModel {
  final String key;

  /// Basic Info
  final String name;
  final String specialization;
  final String doctorClass;

  final String? phone;
  final String? address;

  /// Visit Schedule (Text Format)
  /// Example: "Saturday - Wednesday | 5 PM - 7 PM"
  final String? visitSchedule;

  /// Optional: Active / Inactive
  final bool isActive;

  /// Optional: For local filtering or soft delete
  final int? status;

  const DoctorListModel({
    required this.key,
    required this.name,
    required this.specialization,
    required this.doctorClass,
    this.phone,
    this.address,
    this.visitSchedule,
    this.isActive = true,
    this.status,
  });

  /// ===========================
  /// 🔥 Derived Helpers
  /// ===========================

  bool get hasPhone => phone != null && phone!.isNotEmpty;

  bool get hasSchedule =>
      visitSchedule != null && visitSchedule!.isNotEmpty;

  bool get isInactive => !isActive;

  /// ===========================
  /// 🔥 JSON
  /// ===========================

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'specialization': specialization,
      'doctor_class': doctorClass,
      'phone': phone,
      'address': address,
      'visit_schedule': visitSchedule,
      'is_active': isActive,
      'status': status,
    };
  }

  factory DoctorListModel.fromJson(Map<String, dynamic> json) {
    return DoctorListModel(
      key: json['key'],
      name: json['name'],
      specialization: json['specialization'],
      doctorClass: json['doctor_class'],
      phone: json['phone'],
      address: json['address'],
      visitSchedule: json['visit_schedule'],
      isActive: json['is_active'] ?? true,
      status: _parseInt(json['status']),
    );
  }

  factory DoctorListModel.fromJsonString(String source) =>
      DoctorListModel.fromJson(json.decode(source));

  String toJsonString() => json.encode(toJson());

  /// ===========================
  /// 🔥 CopyWith
  /// ===========================

  DoctorListModel copyWith({
    String? key,
    String? name,
    String? specialization,
    String? doctorClass,
    String? phone,
    String? address,
    String? visitSchedule,
    bool? isActive,
    int? status,
  }) {
    return DoctorListModel(
      key: key ?? this.key,
      name: name ?? this.name,
      specialization: specialization ?? this.specialization,
      doctorClass: doctorClass ?? this.doctorClass,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      visitSchedule: visitSchedule ?? this.visitSchedule,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
    );
  }

  /// ===========================
  /// 🔥 Safe Int Parser
  /// ===========================

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}