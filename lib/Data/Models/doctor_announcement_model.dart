import '../../index/index_main.dart';

class DoctorAnnouncementModel {
  String? key;
  final String? doctorKey;
  final String? doctorName;
  final String? type;
  final String? reason;
  final String? estimatedTime;
  final int? createdAt;
  final String? createdBy;
  final String? date;
  final bool? isActive;

  DoctorAnnouncementModel({
    this.key,
    this.doctorKey,
    this.doctorName,
    this.type,
    this.reason,
    this.estimatedTime,
    this.createdAt,
    this.createdBy,
    this.date,
    this.isActive = true,
  });

  DoctorAnnouncementType get announcementType =>
      DoctorAnnouncementTypeExt.fromValue(type);

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (key != null) data['key'] = key;
    if (doctorKey != null) data['doctor_key'] = doctorKey;
    if (doctorName != null) data['doctor_name'] = doctorName;
    if (type != null) data['type'] = type;
    if (reason != null) data['reason'] = reason;
    if (estimatedTime != null) data['estimated_time'] = estimatedTime;
    if (createdAt != null) data['created_at'] = createdAt;
    if (createdBy != null) data['created_by'] = createdBy;
    if (date != null) data['date'] = date;
    if (isActive != null) data['is_active'] = isActive;
    return data;
  }

  factory DoctorAnnouncementModel.fromJson(Map<String, dynamic> json) {
    return DoctorAnnouncementModel(
      key: json['key'],
      doctorKey: json['doctor_key'],
      doctorName: json['doctor_name'],
      type: json['type'],
      reason: json['reason'],
      estimatedTime: json['estimated_time'],
      createdAt: json['created_at'],
      createdBy: json['created_by'],
      date: json['date'],
      isActive: json['is_active'] ?? true,
    );
  }

  DoctorAnnouncementModel copyWith({
    String? key,
    String? doctorKey,
    String? doctorName,
    String? type,
    String? reason,
    String? estimatedTime,
    int? createdAt,
    String? createdBy,
    String? date,
    bool? isActive,
  }) {
    return DoctorAnnouncementModel(
      key: key ?? this.key,
      doctorKey: doctorKey ?? this.doctorKey,
      doctorName: doctorName ?? this.doctorName,
      type: type ?? this.type,
      reason: reason ?? this.reason,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      date: date ?? this.date,
      isActive: isActive ?? this.isActive,
    );
  }

  factory DoctorAnnouncementModel.create({
    required DoctorAnnouncementType type,
    required String doctorKey,
    required String doctorName,
    String? reason,
    String? estimatedTime,
  }) {
    final now = DateTime.now();
    final date =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final sessionUser = Get.find<UserSession>().user?.user;

    return DoctorAnnouncementModel(
      key: const Uuid().v4(),
      doctorKey: doctorKey,
      doctorName: doctorName,
      type: type.value,
      reason: reason,
      estimatedTime: estimatedTime,
      createdAt: now.millisecondsSinceEpoch,
      createdBy: sessionUser?.uid,
      date: date,
      isActive: true,
    );
  }
}
