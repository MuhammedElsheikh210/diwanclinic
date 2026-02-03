class LegacyQueueModel {
  final String? key;
  final String? clinic_key;
  final String? date; // dd/MM/yyyy
  final int? value; // عدد الحجوزات الورقية في اليوم ده

  LegacyQueueModel({this.key, this.date, this.value,this.clinic_key});

  /// ✅ Convert Model to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (key?.isNotEmpty == true) data['key'] = key;
    if (clinic_key?.isNotEmpty == true) data['clinic_key'] = clinic_key;
    if (date?.isNotEmpty == true) data['date'] = date;
    if (value != null) data['value'] = value;

    return data;
  }

  /// ✅ Create Model from JSON
  factory LegacyQueueModel.fromJson(Map<String, dynamic> json) {
    return LegacyQueueModel(
      key: json['key'],
      clinic_key: json['clinic_key'],
      date: json['date'],
      value: json['value'],
    );
  }

  /// ✅ CopyWith
  LegacyQueueModel copyWith({String? key, String? date, int? value}) {
    return LegacyQueueModel(
      key: key ?? this.key,
      clinic_key: clinic_key ?? this.clinic_key,
      date: date ?? this.date,
      value: value ?? this.value,
    );
  }
}
