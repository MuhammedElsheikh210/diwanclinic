import 'package:firebase_database/firebase_database.dart';
import '../../../../index/index_main.dart';

class SignUpViewModel extends GetxController {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final passwordController = TextEditingController();

  final isNameValid = false.obs;
  final isPhoneValid = false.obs;
  final isAddressValid = false.obs;
  final isPasswordValid = false.obs;

  final UserSession _session = Get.find();

  // ============================================================
  // VALIDATION
  // ============================================================

  void validatePassword(String value) {
    isPasswordValid.value = value.length >= 6;
  }

  void validateName(String value) {
    isNameValid.value = value.trim().length >= 3;
  }

  void validatePhone(String value) {
    isPhoneValid.value = value.trim().length >= 8;
  }

  void validateAddress(String value) {
    isAddressValid.value = value.trim().length >= 5;
  }

  // ============================================================
  // SIGN UP
  // ============================================================

  Future<void> signUp() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final address = addressController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || phone.isEmpty || address.isEmpty || password.isEmpty) {
      Loader.showError("يرجى ملء جميع الحقول");
      return;
    }

    if (password.length < 6) {
      Loader.showError("كلمة المرور ضعيفة");
      return;
    }

    Loader.show();

    try {
      final email = "$phone@link.com";

      final userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCred.user?.uid;

      if (uid == null) {
        Loader.showError("حدث خطأ أثناء إنشاء الحساب");
        return;
      }

      final token = NotificationService().token;

      final baseUser = BaseUser(
        uid: uid,
        name: name,
        phone: phone,
        address: address,
        identifier: email,
        password: password,
        fcmToken: token,
        userType: UserType.patient,
        isProfileCompleted: true,
      );

      final localUser = LocalUser(baseUser);

      await AuthenticationService().addClientsData(
        userclient: localUser,
        voidCallBack: (_) async {
          Loader.dismiss();

          await _finalizeSignUp(localUser);
          await _updateFcmToken(token);
          await _updateClientsSyncStatus();
        },
      );

      Loader.showSuccess("تم إنشاء الحساب بنجاح 🎉");
    } on FirebaseAuthException catch (e) {
      Loader.dismiss();
      Loader.showError(e.message ?? "فشل إنشاء الحساب");
    } catch (e) {
      Loader.dismiss();
      Loader.showError("حدث خطأ غير متوقع");
    }
  }

  // ============================================================
  // FINALIZE (مثل login)
  // ============================================================

  Future<void> _finalizeSignUp(LocalUser user) async {
    await _session.setUser(user);
    await NotificationService().subscribeAfterLogin();

    Get.offAllNamed(mainpage);
  }

  // ============================================================
  // TOKEN SYNC (shared logic)
  // ============================================================

  Future<void> _updateFcmToken(String? token) async {
    if (token == null) return;

    final user = _session.user;

    if (user?.uid == null) return;

    if (user!.user.fcmToken == token) return;

    final updated = user.user.copyWith(fcmToken: token);

    await AuthenticationService().updateClientsData(
      userclient: LocalUser(updated),
      voidCallBack: (_) {},
    );

    await _session.setUser(LocalUser(updated));
  }

  // ============================================================
  // SYNC META
  // ============================================================

  Future<void> _updateClientsSyncStatus() async {
    final ref = FirebaseDatabase.instance.ref("sync_meta/clients");

    await ref.update({
      "last_add_data_timestamp": DateTime.now().millisecondsSinceEpoch,
    });
  }
}
