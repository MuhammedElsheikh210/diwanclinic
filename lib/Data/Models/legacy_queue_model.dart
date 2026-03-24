class LegacyQueueModel {
  final String? key;
  final String? clinic_key;
  final String? doctorKey;
  final String? shiftKey;
  final String? shiftName;
  final String? clinicShiftKey;
  final String? shift_date; // ✅ NEW 🔥
  final String? date;
  final int? value;
  final bool? isClosed;

  LegacyQueueModel({
    this.key,
    this.clinic_key,
    this.doctorKey,
    this.shiftKey,
    this.shiftName,
    this.clinicShiftKey,
    this.shift_date, // ✅ NEW
    this.date,
    this.value,
    this.isClosed,
  });

  /// 🧠 Helper
  bool get isAvailable => isClosed != true;

  /// 🔥 clinic + shift
  String? get generatedClinicShiftKey {
    if (clinic_key == null || shiftKey == null) return null;
    return "${clinic_key!}_${shiftKey!}";
  }

  /// 🔥 NEW → shift + date
  String? get generatedShiftDate {
    if (shiftKey == null || date == null) return null;
    return "${shiftKey!}_${date!}";
  }

  // ------------------------------------------------------------
  // ✅ Convert Model to JSON
  // ------------------------------------------------------------
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (key?.isNotEmpty == true) data['key'] = key;
    if (clinic_key?.isNotEmpty == true) data['clinic_key'] = clinic_key;

    if (doctorKey?.isNotEmpty == true) {
      data['doctorKey'] = doctorKey;
    }

    if (shiftKey?.isNotEmpty == true) data['shiftKey'] = shiftKey;
    if (shiftName?.isNotEmpty == true) data['shiftName'] = shiftName;
    if (date?.isNotEmpty == true) data['date'] = date;
    if (value != null) data['value'] = value;
    if (isClosed != null) data['isClosed'] = isClosed;

    /// ✅ clinicShiftKey
    final clinicShift = generatedClinicShiftKey;
    if (clinicShift != null) {
      data['clinicShiftKey'] = clinicShift;
    }

    /// ✅ NEW shift_date
    final shiftDate = generatedShiftDate;
    if (shiftDate != null) {
      data['shift_date'] = shiftDate;
    }

    return data;
  }

  // ------------------------------------------------------------
  // ✅ From JSON
  // ------------------------------------------------------------
  factory LegacyQueueModel.fromJson(Map<String, dynamic> json) {
    return LegacyQueueModel(
      key: json['key'],
      clinic_key: json['clinic_key'],
      doctorKey: json['doctorKey'],
      shiftKey: json['shiftKey'],
      shiftName: json['shiftName'],
      clinicShiftKey: json['clinicShiftKey'],
      shift_date: json['shift_date'],
      // ✅ NEW
      date: json['date'],
      value: json['value'],
      isClosed: json.containsKey('isClosed') ? json['isClosed'] as bool? : null,
    );
  }

  // ------------------------------------------------------------
  // ✅ CopyWith
  // ------------------------------------------------------------
  LegacyQueueModel copyWith({
    String? key,
    String? clinic_key,
    String? doctorKey,
    String? shiftKey,
    String? shiftName,
    String? date,
    int? value,
    bool? isClosed,
    bool setIsClosedNull = false,
    bool setShiftKeyNull = false,
  }) {
    return LegacyQueueModel(
      key: key ?? this.key,
      clinic_key: clinic_key ?? this.clinic_key,
      doctorKey: doctorKey ?? this.doctorKey,
      shiftKey: setShiftKeyNull ? null : (shiftKey ?? this.shiftKey),
      shiftName: shiftName ?? this.shiftName,
      date: date ?? this.date,
      value: value ?? this.value,
      isClosed: setIsClosedNull ? null : (isClosed ?? this.isClosed),
    );
  }
}
