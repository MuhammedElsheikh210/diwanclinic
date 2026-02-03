import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String? key;
  final String? uid;
  final String? name;
  final String? icon_name;
  final String? categoryType;

  const CategoryEntity({
    this.key,
    this.uid,
    this.name,
    this.icon_name,
    this.categoryType,
  });

  @override
  List<Object?> get props => [key, uid, name, icon_name, categoryType];

  /// ✅ Copy with modifications
  CategoryEntity copyWith({
    String? key,
    String? uid,
    String? name,
    String? iconName,
    String? categoryType,
  }) {
    return CategoryEntity(
      key: key ?? this.key,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      icon_name: iconName ?? this.icon_name,
      categoryType: categoryType ?? this.categoryType,
    );
  }

  /// ✅ From JSON (safe default for missing `icon_name`)
  factory CategoryEntity.fromJson(Map<String, dynamic> json) {
    return CategoryEntity(
      key: json['key'] as String?,
      uid: json['uid'] as String?,
      name: json['name'] as String?,
      categoryType: json['categoryType'] as String?,
      icon_name: (json['icon_name'] as String?)?.isNotEmpty == true
          ? json['icon_name'] as String
          : 'userDoctor', // ✅ Default fallback
    );
  }

  /// ✅ To JSON
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
