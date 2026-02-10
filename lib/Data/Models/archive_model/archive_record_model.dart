class ArchiveRecordModel {
  final String id;
  final String patientId;

  /// key = fieldId
  /// value = entered value
  final Map<String, dynamic> values;

  final DateTime createdAt;

  ArchiveRecordModel({
    required this.id,
    required this.patientId,
    required this.values,
    required this.createdAt,
  });
}
