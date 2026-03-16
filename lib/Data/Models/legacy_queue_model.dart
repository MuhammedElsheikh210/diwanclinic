class LegacyQueueModel {
  final String? key;
  final String? clinic_key;
  final String? shiftKey;
  final String? shiftName; // ✅ NEW
  final String? clinicShiftKey; // concatenated field
  final String? date;
  final int? value;
  final bool? isClosed;

  LegacyQueueModel({
    this.key,
    this.clinic_key,
    this.shiftKey,
    this.shiftName,
    this.clinicShiftKey,
    this.date,
    this.value,
    this.isClosed,
  });

  /// 🧠 Helper
  bool get isAvailable => isClosed != true;

  /// 🔥 Auto generate concatenated value
  String? get generatedClinicShiftKey {
    if (clinic_key == null || shiftKey == null) return null;
    return "${clinic_key!}_${shiftKey!}";
  }

  // ------------------------------------------------------------
  // ✅ Convert Model to JSON
  // ------------------------------------------------------------
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (key?.isNotEmpty == true) data['key'] = key;
    if (clinic_key?.isNotEmpty == true) data['clinic_key'] = clinic_key;
    if (shiftKey?.isNotEmpty == true) data['shiftKey'] = shiftKey;
    if (shiftName?.isNotEmpty == true) data['shiftName'] = shiftName; // ✅ NEW
    if (date?.isNotEmpty == true) data['date'] = date;
    if (value != null) data['value'] = value;
    if (isClosed != null) data['isClosed'] = isClosed;

    /// ✅ Always store concatenated field
    final concatValue = generatedClinicShiftKey;
    if (concatValue != null) {
      data['clinicShiftKey'] = concatValue;
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
      shiftKey: json['shiftKey'],
      shiftName: json['shiftName'],
      // ✅ NEW
      clinicShiftKey: json['clinicShiftKey'],
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
    String? shiftKey,
    String? shiftName, // ✅ NEW
    String? date,
    int? value,
    bool? isClosed,
    bool setIsClosedNull = false,
    bool setShiftKeyNull = false,
  }) {
    return LegacyQueueModel(
      key: key ?? this.key,
      clinic_key: clinic_key ?? this.clinic_key,
      shiftKey: setShiftKeyNull ? null : (shiftKey ?? this.shiftKey),
      shiftName: shiftName ?? this.shiftName,
      // ✅ NEW
      date: date ?? this.date,
      value: value ?? this.value,
      isClosed: setIsClosedNull ? null : (isClosed ?? this.isClosed),
    );
  }
}
