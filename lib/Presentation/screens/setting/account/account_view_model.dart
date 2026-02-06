import 'package:firebase_auth/firebase_auth.dart';
import '../../../../index/index_main.dart';

class AccountViewModel extends GetxController {
  String? doctorName;
  String? doctorPhone;
  String? doctorImage;

  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  /// Load data from local UserClient
  void loadUserData() {
    final user = LocalUser().getUserData();
    doctorName = user.name ?? "الإسم";
    doctorPhone = user.phone ?? "";
    doctorImage = user.image;
    update();
  }

  Future<void> changePassword() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Loader.showError("لم يتم العثور على المستخدم");
        return;
      }

      final oldPass = oldPasswordController.text.trim();
      final newPass = newPasswordController.text.trim();
      final confirmPass = confirmPasswordController.text.trim();

      if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
        Loader.showError("من فضلك أكمل جميع الحقول");
        return;
      }

      if (newPass != confirmPass) {
        Loader.showError("كلمة المرور الجديدة غير متطابقة");
        return;
      }

      final localUser = LocalUser().getUserData();
      final email = "${localUser.phone}@link.com";

      Loader.show();

      // 🔐 Re-auth
      final credential = EmailAuthProvider.credential(
        email: email,
        password: oldPass,
      );

      await user.reauthenticateWithCredential(credential);

      // 🔁 Update password in Firebase Auth
      await user.updatePassword(newPass);

      // 🔄 Update password in Firebase Realtime DB
      final updatedUser = localUser.copyWith(password: newPass);

      await AuthenticationService().updateClientsData(
        userclient: updatedUser,
        voidCallBack: (status) async {
          if (status == ResponseStatus.success) {
             updatedUser.saveLocal();
          }
        },
      );

      oldPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      Loader.dismiss();
      Loader.showSuccess("تم تغيير كلمة المرور بنجاح ✅");
    } on FirebaseAuthException catch (e) {
      Loader.dismiss();

      switch (e.code) {
        case 'wrong-password':
          Loader.showError("كلمة المرور الحالية غير صحيحة");
          break;
        case 'requires-recent-login':
          Loader.showError("يجب تسجيل الدخول مجددًا قبل تغيير كلمة المرور");
          break;
        case 'weak-password':
          Loader.showError("كلمة المرور الجديدة ضعيفة جدًا");
          break;
        default:
          Loader.showError("حدث خطأ: ${e.message}");
      }
    } catch (e) {
      Loader.dismiss();
      Loader.showError("خطأ غير متوقع: $e");
    }
  }
}
