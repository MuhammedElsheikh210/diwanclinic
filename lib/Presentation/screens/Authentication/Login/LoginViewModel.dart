// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../index/index_main.dart';

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

  final UserSession _session = Get.find();

  StreamSubscription? _tokenSub;

  @override
  Future<void> onInit() async {
    super.onInit();

    _listenToTokenChanges();
  }

  @override
  void onClose() {
    _tokenSub?.cancel();
    textEditingController.dispose();
    textEditingControllerPassword.dispose();
    super.onClose();
  }

  // ============================================================
  // 🔔 TOKEN LISTENER (CLEAN)
  // ============================================================

  void _listenToTokenChanges() {
    _tokenSub = FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      await _updateFcmToken(token);
    });
  }

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
  // VALIDATION
  // ============================================================

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

  // ============================================================
  // LOGIN
  // ============================================================

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
        final uid = credential.user?.uid;

        if (uid == null) {
          Loader.showError("حدث خطأ أثناء تسجيل الدخول");
          return;
        }

        Loader.showSuccess("تم تسجيل الدخول بنجاح");
        await getUserData(uid);
      },
    );

    isLoading.value = false;
  }

  // ============================================================
  // CREATE USER
  // ============================================================

  Future<void> saveUserToFirebaseRealtime(String uid) async {
    final token = NotificationService().token;

    final baseUser = BaseUser(
      uid: uid,
      phone: phone.value,
      identifier: "${phone.value}@link.com",
      isProfileCompleted: false,
      fcmToken: token,
      userType: UserType.admin,
      password: password.value,
    );

    final localUser = LocalUser(baseUser);

    await AuthenticationService().addClientsData(
      userclient: localUser,
      voidCallBack: (_) async {
        Loader.dismiss();

        await _finalizeLogin(localUser);
        await _updateFcmToken(token);
      },
    );
  }

  // ============================================================
  // GET USER
  // ============================================================

  Future<void> getUserData(String uid) async {
    await AuthenticationService().getClientsData(
      query: SQLiteQueryParams(where: "uid = ?", whereArgs: [uid], limit: 1),
      voidCallBack: (users) async {
        Loader.dismiss();

        if (users.isEmpty) {
          await saveUserToFirebaseRealtime(uid);
          return;
        }

        final user = users.first;

        await _finalizeLogin(user);
        await _updateFcmToken(NotificationService().token);
      },
    );
  }

  // ============================================================
  // FINALIZE LOGIN
  // ============================================================

  Future<void> _finalizeLogin(LocalUser user) async {
    await _session.setUser(user);
    await _navigateByRole(user.user.userType);
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  Future<void> _navigateByRole(UserType? role) async {
    switch (role) {
      case UserType.pharmacy:
        await openPharmacyApp();
        break;

      default:
        Get.offAllNamed(mainpage);
    }
  }

  // ============================================================
  // ASSISTANT FLOW
  // ============================================================

  Future<void> openPharmacyApp() async {
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
