import 'dart:convert';

class VisitModel {
  final String? key;
  final String? name;
  final String? address;
  final String? phone;
  final String? comment;
  final int? status;

  const VisitModel({
    this.key,
    this.name,
    this.address,
    this.phone,
    this.comment,
    this.status,
  });

  /// ✅ Convert Model to JSON (for Firebase / API)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (key != null && key!.isNotEmpty) data['key'] = key;
    if (name != null && name!.isNotEmpty) data['name'] = name;
    if (address != null && address!.isNotEmpty) data['address'] = address;
    if (phone != null && phone!.isNotEmpty) data['phone'] = phone;
    if (comment != null && comment!.isNotEmpty) data['comment'] = comment;
    if (status != null) data['status'] = status;

    return data;
  }

  /// ✅ Create Model from JSON (from API or SQLite)
  factory VisitModel.fromJson(Map<String, dynamic> json) {
    return VisitModel(
      key: json['key'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      comment: json['comment'],
      status: (json['status'] is int)
          ? json['status'] as int
          : int.tryParse('${json['status']}'),
    );
  }

  /// ✅ Create Model from JSON String
  factory VisitModel.fromJsonString(String source) =>
      VisitModel.fromJson(json.decode(source));

  /// ✅ Convert Model to JSON String
  String toJsonString() => json.encode(toJson());

  /// ✅ CopyWith for immutability
  VisitModel copyWith({
    String? key,
    String? name,
    String? address,
    String? phone,
    String? comment,
    int? status,
  }) {
    return VisitModel(
      key: key ?? this.key,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      comment: comment ?? this.comment,
      status: status ?? this.status,
    );
  }

  /// ✅ Human-readable printout (for debugging)
  @override
  String toString() {
    return 'VisitModel(key: $key, name: $name, address: $address, phone: $phone, comment: $comment, status: $status)';
  }

  /// ✅ Equality override (useful for tests, state comparison)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VisitModel &&
        other.key == key &&
        other.name == name &&
        other.address == address &&
        other.phone == phone &&
        other.comment == comment &&
        other.status == status;
  }

  @override
  int get hashCode {
    return key.hashCode ^
    name.hashCode ^
    address.hashCode ^
    phone.hashCode ^
    comment.hashCode ^
    status.hashCode;
  }
}
