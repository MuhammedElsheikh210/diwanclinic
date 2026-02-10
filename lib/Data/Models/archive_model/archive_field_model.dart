enum ArchiveFieldType { text, number }

class ArchiveFormModel {
  final String id;
  final List<ArchiveFieldModel> fields;

  ArchiveFormModel({
    required this.id,
    required this.fields,
  });

  factory ArchiveFormModel.fromJson(
      String id,
      Map<String, dynamic> json,
      ) {
    return ArchiveFormModel(
      id: id,
      fields: (json['fields'] as List)
          .map((e) => ArchiveFieldModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fields': fields.map((e) => e.toJson()).toList(),
    };
  }
}


class ArchiveFieldModel {
  final String key;
  final ArchiveFieldType type;

  ArchiveFieldModel({required this.key, required this.type});

  factory ArchiveFieldModel.fromJson(Map<String, dynamic> json) {
    return ArchiveFieldModel(
      key: json['key'],
      type: ArchiveFieldType.values.firstWhere((e) => e.name == json['type']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'key': key, 'type': type.name};
  }
}
