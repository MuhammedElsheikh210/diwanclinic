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

      // retrieve "email" as we constructed it during login
      final localUser = LocalUser().getUserData();
      final email = "${localUser.phone}@link.com";

      if (email.isEmpty) {
        Loader.showError("تعذر العثور على البريد المرتبط بالحساب");
        return;
      }

      Loader.show();

      // ✅ Reauthenticate with the simulated email + old password
      final credential = EmailAuthProvider.credential(
        email: email,
        password: oldPass,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPass);

      // 🔹 Update local saved user model
      final updatedUser = LocalUser().getUserData();
      updatedUser.password = newPass;
      AuthenticationService().updateClientsData(
        userclient: updatedUser,
        voidCallBack: (ResponseStatus p1) {
          Loader.dismiss();
          LocalUser().saveLocal();
        },
      );

      Loader.dismiss();
      oldPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      Loader.showSuccess("تم تغيير كلمة المرور بنجاح ✅");
    } on FirebaseAuthException catch (e) {
      Loader.dismiss();

      if (e.code == 'wrong-password') {
        Loader.showError("كلمة المرور الحالية غير صحيحة");
      } else if (e.code == 'user-mismatch') {
        Loader.showError("هذا الحساب غير متطابق مع بيانات الدخول الحالية");
      } else if (e.code == 'requires-recent-login') {
        Loader.showError("يجب تسجيل الدخول مجددًا قبل تغيير كلمة المرور");
      } else if (e.code == 'weak-password') {
        Loader.showError("كلمة المرور الجديدة ضعيفة جدًا");
      } else {
        Loader.showError("حدث خطأ أثناء تغيير كلمة المرور: ${e.message}");
      }
    } catch (e) {
      Loader.dismiss();
      Loader.showError("حدث خطأ غير متوقع: $e");
    }
  }
}
