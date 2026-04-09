// ignore_for_file: non_constant_identifier_names

import 'package:dartz/dartz.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
    super.onInit();

    LocalUser().removeLocalUser();

    /// 🔥 check current token
    final currentToken = NotificationService().token;
    debugPrint("🧪 INITIAL TOKEN => $currentToken");

    /// 🔥 Listen لأي تغيير في FCM token
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      debugPrint("🔥 NEW TOKEN FROM LISTENER => $newToken");

      final user = LocalUser().getUserData();

      debugPrint("👤 CURRENT USER UID => ${user.uid}");

      if (user.uid != null) {
        final updatedUser = user.copyWith(fcmToken: newToken);

        debugPrint("📤 UPDATING USER WITH TOKEN => $newToken");

        await AuthenticationService().updateClientsData(
          userclient: updatedUser,
          voidCallBack: (_) {
            debugPrint("✅ USER UPDATED WITH NEW TOKEN");
          },
        );

        updatedUser.saveLocal();
      }
    });
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
    final token = NotificationService().token;

    debugPrint("🧪 TOKEN BEFORE CREATE USER => $token");

    final LocalUser userClient = LocalUser(
      uid: uid,
      key: uid,
      phone: phone.value,
      identifier: "${phone.value}@link.com",
      isCompleteProfile: 0,
      fcmToken: token,
      userType: UserType.admin,
      password: password.value,
    );

    debugPrint("📦 USER TO SAVE => ${userClient.toJson()}");

    AuthenticationService().addClientsData(
      userclient: userClient,
      voidCallBack: (_) async {
        debugPrint("✅ USER SAVED TO FIREBASE");

        Loader.dismiss();
        await _finalizeLogin(userClient);

        await _syncFcmTokenWithUser(userClient);
      },
    );
  }

  // ─────────────────────────────
  // GET USER DATA
  // ─────────────────────────────

  Future<void> getUserData(String uid) async {
    await AuthenticationService().getClientsData(
      query: SQLiteQueryParams(where: "token = ?", whereArgs: [uid], limit: 1),
      voidCallBack: (users) async {
        Loader.dismiss();

        if (users.isEmpty || users.first == null) {
          await saveUserToFirebaseRealtime(uid);
          return;
        }

        var user = users.first!;

        await _finalizeLogin(user);

        // 🔥 sync token بعد login
        await _syncFcmTokenWithUser(user);
      },
    );
  }

  // ─────────────────────────────
  // SYNC TOKEN
  // ─────────────────────────────

  Future<void> _syncFcmTokenWithUser(LocalUser user) async {
    final token = NotificationService().token;

    debugPrint("🧪 SYNC TOKEN => $token");
    debugPrint("🧪 USER OLD TOKEN => ${user.fcmToken}");

    if (token == null) {
      debugPrint("❌ TOKEN STILL NULL - SKIP UPDATE");
      return;
    }

    if (user.fcmToken == token) {
      debugPrint("✅ TOKEN ALREADY SAME - NO UPDATE");
      return;
    }

    final updatedUser = user.copyWith(fcmToken: token);

    debugPrint("📤 UPDATING USER TOKEN TO => $token");

    await AuthenticationService().updateClientsData(
      userclient: updatedUser,
      voidCallBack: (_) {
        debugPrint("✅ TOKEN UPDATED IN FIREBASE");
      },
    );

    updatedUser.saveLocal();
  }

  // ─────────────────────────────
  // FINALIZE LOGIN
  // ─────────────────────────────

  Future<void> _finalizeLogin(LocalUser user) async {
    user.saveLocal();

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
        Get.offAllNamed(mainpage);
        break;

      case UserType.pharmacy:
        await openAssistantApp();
        break;

      default:
        Get.offAllNamed(mainpage);
    }
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
