

import 'package:diwanclinic/Data/Models/archive_model/archive_field_model.dart';

class ArchiveFieldModel {
  final String id;
  final String title;
  final ArchiveFieldType type;
  final int order;

  ArchiveFieldModel({
    required this.id,
    required this.title,
    required this.type,
    required this.order,
  });

  /// ================= FROM JSON =================

  factory ArchiveFieldModel.fromJson(Map<String, dynamic> json) {
    return ArchiveFieldModel(
      id: json['id'].toString(),
      title: json['title'],
      type: ArchiveFieldType.values.firstWhere(
            (e) => e.name == json['type'],
      ),
      order: json['order'] ?? 0,
    );
  }

  /// ================= TO JSON =================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'order': order,
    };
  }
}
