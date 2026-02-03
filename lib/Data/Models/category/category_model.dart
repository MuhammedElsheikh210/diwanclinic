import '../../../index/index_main.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required String key,
    required String uid,
    required String categoryType,
    required String name,
    required String icon_name, // ✅ Add icon_name
  }) : super(
    key: key,
    uid: uid,
    name: name,
    categoryType: categoryType,
    icon_name: icon_name,
  );

  /// ✅ Create a `CategoryModel` from JSON (with null-safety)
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      key: json['key'] as String? ?? '',
      uid: json['uid'] as String? ?? '',
      categoryType: json['categoryType'] as String? ?? '',
      name: json['name'] as String? ?? '',
      icon_name: (json['icon_name'] as String?)?.isNotEmpty == true
          ? json['icon_name'] as String
          : 'userDoctor', // ✅ Fallback if missing
    );
  }

  /// ✅ Convert to JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'uid': uid,
      'name': name,
      'categoryType': categoryType,
      'icon_name': icon_name ?? 'userDoctor', // ✅ Never null
    };
  }
}
