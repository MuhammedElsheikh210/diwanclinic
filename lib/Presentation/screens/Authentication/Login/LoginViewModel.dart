// ignore_for_file: non_constant_identifier_names

import 'package:dartz/dartz.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../Domain/UseCases/Firebase_UseCases/FirebaseSignIn_USeCase.dart';
import '../../../../index/index_main.dart';
import '../../../screens/sync_assistant_medicines/sync_medicine_view.dart';
import '../../../screens/sync_assistant_medicines/sync_medicine_view_model.dart';

class LoginViewModel extends GetxController {
  final phone = ''.obs;
  final password = ''.obs;

  final isPhoneValid = false.obs;
  final isPasswordValid = false.obs;
  final showPassword = false.obs;
  final isLoading = false.obs;

  final phoneKeyLogin = GlobalKey<FormState>();

  final textEditingController = TextEditingController();
  final textEditingControllerPassword = TextEditingController();

  @override
  Future<void> onInit() async {
    LocalUser().removeLocalUser();
    super.onInit();
  }

  @override
  void onClose() {
    textEditingController.dispose();
    textEditingControllerPassword.dispose();
    super.onClose();
  }

  // ─────────────────────────────
  // Validation
  // ─────────────────────────────

  void validatePhone(String value) {
    phone.value = value.trim();
    isPhoneValid.value = value.trim().isNotEmpty;
  }

  void validatePassword(String value) {
    password.value = value;
    isPasswordValid.value = value.isNotEmpty && value.length >= 6;
  }

  void togglePasswordVisibility() {
    showPassword.toggle();
  }

  // ─────────────────────────────
  // LOGIN
  // ─────────────────────────────

  Future<void> loginData() async {
    if (isLoading.value) return;

    isLoading.value = true;
    Loader.show();

    final firebaseSignInUseCase = initController(
      () => FirebaseSignIn_UseCase(Get.find()),
    );

    final Either<AppError, UserCredential> result = await firebaseSignInUseCase(
      FirebaseAuthModel(
        "${phone.value}@link.com",
        textEditingControllerPassword.text.isEmpty
            ? phone.value
            : textEditingControllerPassword.text,
      ),
    );

    result.fold(
      (error) {
        Loader.showError(error.messege);
      },
      (credential) async {
        Loader.showSuccess("تم تسجيل الدخول بنجاح");
        await getUserData(credential.user?.uid ?? "");
      },
    );

    isLoading.value = false;
  }

  // ─────────────────────────────
  // CREATE USER
  // ─────────────────────────────

  Future<void> saveUserToFirebaseRealtime(String uid) async {
    final newToken = NotificationService().token;

    final LocalUser userClient = LocalUser(
      uid: uid,
      key: const Uuid().v4(),
      phone: phone.value,
      identifier: "${phone.value}@link.com",
      isCompleteProfile: 0,
      fcmToken: newToken,
      // ممكن يكون null عادي
      userType: UserType.admin,
      password: password.value,
    );

    AuthenticationService().addClientsData(
      userclient: userClient,
      voidCallBack: (_) async {
        Loader.dismiss();
        await _finalizeLogin(userClient);
      },
    );
  }

  // ─────────────────────────────
  // GET USER DATA
  // ─────────────────────────────

  Future<void> getUserData(String uid) async {
    AuthenticationService().getSingleClientsData(
      filrebaseFilter: FirebaseFilter(equalTo: uid, orderBy: "token"),
      voidCallBack: (user) async {
        Loader.dismiss();

        final newToken = await ConstantsData.firebaseToken();
        print("new tolen is ${newToken}");

        if (user == null) {
          await saveUserToFirebaseRealtime(uid);
          return;
        }

        // تحديث التوكن فقط لو موجود
        if (newToken != null &&
            (user.fcmToken == null || user.fcmToken != newToken)) {
          final updatedUser = user.copyWith(fcmToken: newToken);

          await AuthenticationService().updateClientsData(
            userclient: updatedUser,
            voidCallBack: (_) {},
          );

          user = updatedUser;
        }

        await _finalizeLogin(user);
      },
    );
  }

  // ─────────────────────────────
  // FINALIZE LOGIN
  // ─────────────────────────────

  Future<void> _finalizeLogin(LocalUser user) async {
    user.saveLocal();

    // subscribe آمن (NotificationService فيه حماية pending)
    await NotificationService().subscribeAfterLogin();

    await _navigateByRole(user.userType);
  }

  // ─────────────────────────────
  // NAVIGATION
  // ─────────────────────────────

  Future<void> _navigateByRole(UserType? role) async {
    switch (role) {
      case UserType.assistant:
      case UserType.doctor:
        Get.offAllNamed(syncView);
        break;

      case UserType.pharmacy:
        await openAssistantApp();
        break;

      default:
        await _updateClientsSyncStatus();
        Get.offAllNamed(mainpage);
    }
  }

  // ─────────────────────────────
  // SYNC UPDATE
  // ─────────────────────────────

  Future<void> _updateClientsSyncStatus() async {
    final ref = FirebaseDatabase.instance.ref("sync_meta/clients");

    await ref.update({
      "last_add_data_timestamp": DateTime.now().millisecondsSinceEpoch,
    });
  }

  // ─────────────────────────────
  // ASSISTANT DB CHECK
  // ─────────────────────────────

  Future<void> openAssistantApp() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'medicines.db');

    final exists = await databaseExists(path);

    if (!exists) {
      Get.offAll(
        () => const SyncMedicineView(),
        binding: SyncMedicineBinding(),
      );
      return;
    }

    final db = await openDatabase(path);

    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM medicines'),
    );

    if (count == null || count == 0) {
      Get.offAll(
        () => const SyncMedicineView(),
        binding: SyncMedicineBinding(),
      );
    } else {
      Get.offAll(() => const MainPage());
    }
  }
}
