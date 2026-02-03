class SpecialistModel {
  final String? key;
  final String? title;
  final String? image;

  SpecialistModel({this.key, this.title, this.image});

  /// ✅ Convert Entity to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (key != null && key!.isNotEmpty) data['key'] = key;
    if (title != null && title!.isNotEmpty) data['title'] = title;
    if (image != null && image!.isNotEmpty) data['image'] = image;
    return data;
  }

  /// ✅ Create Entity from JSON
  factory SpecialistModel.fromJson(Map<String, dynamic> json) {
    return SpecialistModel(
      key: json['key'],
      title: json['title'],
      image: json['image'],
    );
  }

  /// ✅ CopyWith
  SpecialistModel copyWith({String? key, String? title, String? image}) {
    return SpecialistModel(
      key: key ?? this.key,
      title: title ?? this.title,
      image: image ?? this.image,
    );
  }
}
