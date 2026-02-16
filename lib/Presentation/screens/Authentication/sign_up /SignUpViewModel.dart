import 'package:firebase_database/firebase_database.dart';

import '../../../../index/index_main.dart';

class SignUpViewModel extends GetxController {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  RxBool isNameValid = false.obs;
  RxBool isPhoneValid = false.obs;
  RxBool isAddressValid = false.obs;
  final passwordController = TextEditingController();

  RxBool isPasswordValid = false.obs;

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

  /// ⭐ MAIN SIGN-UP LOGIC ⭐
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

      final uid = userCred.user?.uid ?? "";
      final generatedKey = const Uuid().v4();

      final newUser = LocalUser(
        uid: uid,
        key: generatedKey,
        name: name,
        phone: phone,
        address: address,
        fcmToken: await ConstantsData.firebaseToken(),
        userType: UserType.patient,
        identifier: email,
        password: password,
      );

      await AuthenticationService().addClientsData(
        userclient: newUser,
        voidCallBack: (_) async {
          newUser.saveLocal();

          // 2️⃣ 🔥 notify others that clients changed
          await _updateClientsSyncStatus();
        },
      );

      Loader.dismiss();
      Loader.showSuccess("تم إنشاء الحساب بنجاح 🎉");

      Get.offAll(() => const MainPage(initialIndex: 0), binding: Binding());
    } on FirebaseAuthException catch (e) {
      Loader.dismiss();
      Loader.showError(e.message ?? "فشل إنشاء الحساب");
    } catch (e) {
      Loader.dismiss();
      Loader.showError("حدث خطأ غير متوقع");
    }
  }

  Future<void> _updateClientsSyncStatus() async {
    final ref = FirebaseDatabase.instance.ref("sync_meta/clients");

    await ref.update({
      "last_add_data_timestamp": DateTime.now().millisecondsSinceEpoch,
    });
  }
}
