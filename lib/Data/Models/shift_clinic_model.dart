class ShiftModel {
  final String? key;
  final String? clinicKey;
  final String? doctorKey;
  final String? name; // e.g., Morning, Evening
  final String? dayOfWeek; // e.g., Sunday, Monday
  final String? startTime; // e.g., 09:00
  final String? endTime; // e.g., 13:00
  final int? capacity; // max patients allowed per shift
  final String? uid; // owner (doctor/clinic manager)

  ShiftModel({
    this.key,
    this.clinicKey,
    this.doctorKey,
    this.name,
    this.dayOfWeek,
    this.startTime,
    this.endTime,
    this.capacity,
    this.uid,
  });

  /// ✅ Factory for JSON → Model
  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      key: json['key'] as String?,
      clinicKey: json['clinicKey'] as String?,
      doctorKey: json['doctorKey'],
      name: json['name'] as String?,
      dayOfWeek: json['dayOfWeek'] as String?,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      capacity:
          json['capacity'] is int
              ? json['capacity'] as int
              : int.tryParse(json['capacity']?.toString() ?? ''),
      uid: json['uid'] as String?,
    );
  }

  /// ✅ Convert Model → JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (key?.isNotEmpty == true) data['key'] = key;
    if (clinicKey?.isNotEmpty == true) data['clinicKey'] = clinicKey;
    if (doctorKey?.isNotEmpty == true) data['doctorKey'] = doctorKey;
    if (name?.isNotEmpty == true) data['name'] = name;
    if (dayOfWeek?.isNotEmpty == true) data['dayOfWeek'] = dayOfWeek;
    if (startTime?.isNotEmpty == true) data['startTime'] = startTime;
    if (endTime?.isNotEmpty == true) data['endTime'] = endTime;
    if (capacity != null) data['capacity'] = capacity;
    if (uid?.isNotEmpty == true) data['uid'] = uid;
    return data;
  }

  /// ✅ CopyWith for updates
  ShiftModel copyWith({
    String? key,
    String? clinicKey,
    String? doctorKey,
    String? name,
    String? dayOfWeek,
    String? startTime,
    String? endTime,
    int? capacity,
    String? uid,
  }) {
    return ShiftModel(
      key: key ?? this.key,
      clinicKey: clinicKey ?? this.clinicKey,
      doctorKey: doctorKey ?? this.doctorKey,
      name: name ?? this.name,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      capacity: capacity ?? this.capacity,
      uid: uid ?? this.uid,
    );
  }
}
