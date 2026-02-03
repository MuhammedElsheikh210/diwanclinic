class UsersEntity {
  final String? key;
  final String? name;
  final String? whatsappPhone;
  final String? uid;

  UsersEntity({
    this.key,
    this.name,
    this.whatsappPhone,
    this.uid,
  });

  /// ✅ Convert Entity to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (key != null && key!.isNotEmpty) data['key'] = key;
    if (name != null && name!.isNotEmpty) data['name'] = name;
    if (uid != null && uid!.isNotEmpty) data['uid'] = uid;
    if (whatsappPhone != null && whatsappPhone!.isNotEmpty) {
      data['whatsapp_phone'] = whatsappPhone;
    }
    return data;
  }

  /// ✅ Create Entity from JSON
  factory UsersEntity.fromJson(Map<String, dynamic> json) {
    return UsersEntity(
      key: json['key'],
      name: json['name'],
      whatsappPhone: json['whatsapp_phone'],
      uid: json['uid'],
    );
  }

  /// ✅ CopyWith
  UsersEntity copyWith({
    String? key,
    String? name,
    String? whatsappPhone,
    String? uid,
  }) {
    return UsersEntity(
      key: key ?? this.key,
      name: name ?? this.name,
      whatsappPhone: whatsappPhone ?? this.whatsappPhone,
      uid: uid ?? this.uid,
    );
  }
}
