// import '../../../index/index_main.dart';
//
// class UsersModel extends UsersEntity {
//   UsersModel({String? key, String? name, String? whatsappPhone, String? uid})
//     : super(key: key, name: name, whatsappPhone: whatsappPhone, uid: uid);
//
//   /// ✅ **Convert JSON to `UsersModel`**
//   factory UsersModel.fromJson(Map<String, dynamic> json) {
//     return UsersModel(
//       key: json['key'] ?? '',
//       name: json['name'] ?? '',
//       whatsappPhone: json['whatsapp_phone'] ?? '',
//       uid: json['uid'] ?? '',
//     );
//   }
//
//   /// ✅ **Convert `UsersModel` to JSON**
//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'key': key,
//       'name': name,
//       'whatsapp_phone': whatsappPhone,
//       'uid': uid,
//     };
//   }
//
//   /// ✅ **Create a new instance with updated fields**
//   @override
//   UsersModel copyWith({
//     String? key,
//     String? name,
//     String? whatsappPhone,
//     String? uid,
//   }) {
//     return UsersModel(
//       key: key ?? this.key ?? '',
//       name: name ?? this.name ?? '',
//       whatsappPhone: whatsappPhone ?? this.whatsappPhone ?? '',
//       uid: uid ?? this.uid ?? '',
//     );
//   }
// }
