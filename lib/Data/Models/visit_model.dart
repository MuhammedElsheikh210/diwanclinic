import 'dart:convert';

class VisitModel {
  final String? key;

  /// Doctor Info
  final String? name;
  final String? specialization;
  final String? doctorClass;
  final String? address;
  final String? phone;

  /// Doctor Fixed Location
  final double? doctorLat;
  final double? doctorLng;

  /// Visit Date & Time
  final String? visitDate; // yyyy-MM-dd
  final String? visitTime; // HH:mm
  final int? visitTimestamp; // sorting only

  final String? visitStatus; // scheduled | completed | not_completed
  final String? notCompletedReason;

  /// Check-In
  final double? checkInLat;
  final double? checkInLng;
  final int? checkInTimestamp;

  /// Sales Status
  final String? doctorSalesStatus; // deal | follow_up | not_interested
  final int? followUpTimestamp;

  /// Four Steps
  final bool step1TrainAssistantDemo;
  final String? assistantName;
  final String? assistantPrivatePhone;

  final bool step2DoctorPresentation;
  final String? doctorPrivateWhatsapp;

  final bool step3TrainAssistant;
  final bool step4CreateAccount;

  final String? comment;
  final int? status;

  const VisitModel({
    this.key,
    this.name,
    this.specialization,
    this.doctorClass,
    this.address,
    this.phone,
    this.doctorLat,
    this.doctorLng,
    this.visitDate,
    this.visitTime,
    this.visitTimestamp,
    this.visitStatus,
    this.notCompletedReason,
    this.checkInLat,
    this.checkInLng,
    this.checkInTimestamp,
    this.doctorSalesStatus,
    this.followUpTimestamp,
    this.step1TrainAssistantDemo = false,
    this.assistantName,
    this.assistantPrivatePhone,
    this.step2DoctorPresentation = false,
    this.doctorPrivateWhatsapp,
    this.step3TrainAssistant = false,
    this.step4CreateAccount = false,
    this.comment,
    this.status,
  });

  /// ===========================
  /// 🔥 Derived Helpers
  /// ===========================

  bool get isCompleted => visitStatus == "completed";

  bool get isNotCompleted => visitStatus == "not_completed";

  bool get isScheduled => visitStatus == "scheduled";

  bool get isTargetCompleted => step4CreateAccount;

  bool get needsFollowUp => doctorSalesStatus == "follow_up";

  bool get isCheckedIn => checkInLat != null && checkInLng != null;

  /// ===========================
  /// 🔥 JSON
  /// ===========================

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'specialization': specialization,
      'doctor_class': doctorClass,
      'address': address,
      'phone': phone,
      'doctor_lat': doctorLat,
      'doctor_lng': doctorLng,
      'visit_date': visitDate,
      'visit_time': visitTime,
      'visit_timestamp': visitTimestamp,
      'visit_status': visitStatus,
      'not_completed_reason': notCompletedReason,
      'checkin_lat': checkInLat,
      'checkin_lng': checkInLng,
      'checkin_timestamp': checkInTimestamp,
      'doctor_sales_status': doctorSalesStatus,
      'follow_up_timestamp': followUpTimestamp,
      'step1_train_demo': step1TrainAssistantDemo,
      'assistant_name': assistantName,
      'assistant_private_phone': assistantPrivatePhone,
      'step2_doctor_presentation': step2DoctorPresentation,
      'doctor_private_whatsapp': doctorPrivateWhatsapp,
      'step3_train_assistant': step3TrainAssistant,
      'step4_create_account': step4CreateAccount,
      'comment': comment,
      'status': status,
    };
  }

  factory VisitModel.fromJson(Map<String, dynamic> json) {
    return VisitModel(
      key: json['key'],
      name: json['name'],
      specialization: json['specialization'],
      doctorClass: json['doctor_class'],
      address: json['address'],
      phone: json['phone'],

      doctorLat: (json['doctor_lat'] as num?)?.toDouble(),
      doctorLng: (json['doctor_lng'] as num?)?.toDouble(),

      visitDate: json['visit_date'],
      visitTime: json['visit_time'],
      visitTimestamp: _parseInt(json['visit_timestamp']),

      visitStatus: json['visit_status'],
      notCompletedReason: json['not_completed_reason'],

      checkInLat: (json['checkin_lat'] as num?)?.toDouble(),
      checkInLng: (json['checkin_lng'] as num?)?.toDouble(),
      checkInTimestamp: _parseInt(json['checkin_timestamp']),

      doctorSalesStatus: json['doctor_sales_status'],
      followUpTimestamp: _parseInt(json['follow_up_timestamp']),

      step1TrainAssistantDemo: json['step1_train_demo'] ?? false,
      assistantName: json['assistant_name'],
      assistantPrivatePhone: json['assistant_private_phone'],
      step2DoctorPresentation: json['step2_doctor_presentation'] ?? false,
      doctorPrivateWhatsapp: json['doctor_private_whatsapp'],
      step3TrainAssistant: json['step3_train_assistant'] ?? false,
      step4CreateAccount: json['step4_create_account'] ?? false,

      comment: json['comment'],
      status: _parseInt(json['status']),
    );
  }

  factory VisitModel.fromJsonString(String source) =>
      VisitModel.fromJson(json.decode(source));

  String toJsonString() => json.encode(toJson());

  /// ===========================
  /// 🔥 CopyWith
  /// ===========================

  VisitModel copyWith({
    String? key,
    String? name,
    String? specialization,
    String? doctorClass,
    String? address,
    String? phone,
    double? doctorLat,
    double? doctorLng,
    String? visitDate,
    String? visitTime,
    int? visitTimestamp,
    String? visitStatus,
    String? notCompletedReason,
    double? checkInLat,
    double? checkInLng,
    int? checkInTimestamp,
    String? doctorSalesStatus,
    int? followUpTimestamp,
    bool? step1TrainAssistantDemo,
    String? assistantName,
    String? assistantPrivatePhone,
    bool? step2DoctorPresentation,
    String? doctorPrivateWhatsapp,
    bool? step3TrainAssistant,
    bool? step4CreateAccount,
    String? comment,
    int? status,
  }) {
    return VisitModel(
      key: key ?? this.key,
      name: name ?? this.name,
      specialization: specialization ?? this.specialization,
      doctorClass: doctorClass ?? this.doctorClass,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      doctorLat: doctorLat ?? this.doctorLat,
      doctorLng: doctorLng ?? this.doctorLng,
      visitDate: visitDate ?? this.visitDate,
      visitTime: visitTime ?? this.visitTime,
      visitTimestamp: visitTimestamp ?? this.visitTimestamp,
      visitStatus: visitStatus ?? this.visitStatus,
      notCompletedReason: notCompletedReason ?? this.notCompletedReason,
      checkInLat: checkInLat ?? this.checkInLat,
      checkInLng: checkInLng ?? this.checkInLng,
      checkInTimestamp: checkInTimestamp ?? this.checkInTimestamp,
      doctorSalesStatus: doctorSalesStatus ?? this.doctorSalesStatus,
      followUpTimestamp: followUpTimestamp ?? this.followUpTimestamp,
      step1TrainAssistantDemo:
          step1TrainAssistantDemo ?? this.step1TrainAssistantDemo,
      assistantName: assistantName ?? this.assistantName,
      assistantPrivatePhone:
          assistantPrivatePhone ?? this.assistantPrivatePhone,
      step2DoctorPresentation:
          step2DoctorPresentation ?? this.step2DoctorPresentation,
      doctorPrivateWhatsapp:
          doctorPrivateWhatsapp ?? this.doctorPrivateWhatsapp,
      step3TrainAssistant: step3TrainAssistant ?? this.step3TrainAssistant,
      step4CreateAccount: step4CreateAccount ?? this.step4CreateAccount,
      comment: comment ?? this.comment,
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
