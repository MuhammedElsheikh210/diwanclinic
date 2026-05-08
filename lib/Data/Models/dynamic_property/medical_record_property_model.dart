class MedicalRecordPropertyModel {
  /// ✅ Property unique key
  final String? key;

  /// ✅ Related category
  final String? categoryKey;

  /// ✅ Property name
  /// مثال: وزن الجنين
  final String? label;

  /// ✅ text - number - date
  final String? type;

  /// ✅ optional while filling medical record
  dynamic value;

  MedicalRecordPropertyModel({
    this.key,
    this.categoryKey,
    this.label,
    this.type,
    this.value,
  });

  /// ✅ Convert Model to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (key?.isNotEmpty == true) {
      data['key'] = key;
    }

    if (categoryKey?.isNotEmpty == true) {
      data['category_key'] = categoryKey;
    }

    if (label?.isNotEmpty == true) {
      data['label'] = label;
    }

    if (type?.isNotEmpty == true) {
      data['type'] = type;
    }

    if (value != null) {
      data['value'] = value;
    }

    return data;
  }

  /// ✅ Create Model from JSON
  factory MedicalRecordPropertyModel.fromJson(Map<String, dynamic> json) {
    return MedicalRecordPropertyModel(
      key: json['key'],

      categoryKey: json['category_key'],

      label: json['label'],

      type: json['type'],

      value: json['value'],
    );
  }

  /// ✅ CopyWith
  MedicalRecordPropertyModel copyWith({
    String? key,
    String? categoryKey,
    String? label,
    String? type,
    dynamic value,
  }) {
    return MedicalRecordPropertyModel(
      key: key ?? this.key,

      categoryKey: categoryKey ?? this.categoryKey,

      label: label ?? this.label,

      type: type ?? this.type,

      value: value ?? this.value,
    );
  }
}
