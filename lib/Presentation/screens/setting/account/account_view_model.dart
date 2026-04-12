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
    final user = Get.find<UserSession>().user;

    doctorName = user?.name ?? "الإسم";
    doctorPhone = user?.phone ?? "";
    doctorImage = user?.profileImage;
    update();
  }

  Future<void> changePassword() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser == null) {
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

      final localUser = Get.find<UserSession>().user;

      if (localUser == null) {
        Loader.showError("❌ المستخدم غير موجود");
        return;
      }

      final base = localUser.user;

      final email = "${base.phone}@link.com";

      Loader.show();

      // ============================================================
      // 🔐 Re-auth
      // ============================================================

      final credential = EmailAuthProvider.credential(
        email: email,
        password: oldPass,
      );

      await firebaseUser.reauthenticateWithCredential(credential);

      // ============================================================
      // 🔁 Update Firebase Auth
      // ============================================================

      await firebaseUser.updatePassword(newPass);

      // ============================================================
      // 🧠 Build Updated User
      // ============================================================

      BaseUser updatedBase;

      if (base is AssistantUser) {
        updatedBase = AssistantUser(
          uid: base.uid,
          name: base.name,
          phone: base.phone,
          identifier: base.identifier,
          password: newPass,

          clinicKey: base.clinicKey,
          doctorKey: base.doctorKey,
          transferNumber: base.transferNumber,
          isInstaPay: base.isInstaPay,

          userType: base.userType,
          isProfileCompleted: base.isProfileCompleted,
        );
      } else {
        updatedBase = base.copyWith(password: newPass);
      }

      final updatedUser = LocalUser(updatedBase);

      // ============================================================
      // 💾 Update DB
      // ============================================================

      await AuthenticationService().updateClientsData(
        userclient: updatedUser,
        voidCallBack: (status) async {
          if (status == ResponseStatus.success) {
            // ✅ update session بدل saveLocal
            await Get.find<UserSession>().updateUser(updatedBase);
          }
        },
      );

      // ============================================================
      // 🧹 Clear fields
      // ============================================================

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
