// import '../../../index/index_main.dart';
//
// extension SaveLocalUserData on LocalUser {
//   void saveLocal({Function? saveCallback}) {
//     StorageService().setData(Strings.userkey, toJson()).then((value) {
//       if (value) {
//         saveCallback?.call();
//       } else {
//         Loader.showError("لم يتم الحفظ محلياً"); // "Not saved locally"
//       }
//     });
//   }
//
//   LocalUser getUserData() {
//     final data = StorageService().getData(Strings.userkey);
//     if (data != null) {
//       return LocalUser.fromJson(data);
//     }
//     return LocalUser();
//   }
//
//   Future<void> removeLocalUser() async {
//     await StorageService().remove(Strings.userkey);
//   }
// }
