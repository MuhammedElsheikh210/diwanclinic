// ignore_for_file: non_constant_identifier_names, unused_local_variable, unnecessary_null_comparison, unrelated_type_equality_checks

import 'package:dartz/dartz.dart';
import 'package:diwanclinic/Presentation/screens/sync_assistant_medicines/sync_medicine_view.dart';
import 'package:diwanclinic/Presentation/screens/sync_assistant_medicines/sync_medicine_view_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../Domain/UseCases/Firebase_UseCases/FirebaseSignIn_USeCase.dart';
import '../../../../index/index_main.dart';

class LoginViewModel extends GetxController {
  // Reactive fields
  final phone = ''.obs;
  final password = ''.obs;
  final isPhoneValid = false.obs;
  final isPasswordValid = false.obs;
  final showPassword = false.obs;
  final phoneKeyLogin = GlobalKey<FormState>();
  final textEditingController = TextEditingController();
  final textEditingControllerPassword = TextEditingController();

  @override
  Future<void> onInit() async {
    LocalUser().removeLocalUser();
    super.onInit();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    textEditingControllerPassword.dispose();
    super.dispose();
  }

  // Validation check for phone
  void validatePhone(String value) {
    phone.value = value;
    isPhoneValid.value = value.isNotEmpty; // Valid if not empty
    update();
  }

  // Validation check for password
  void validatePassword(String value) {
    isPasswordValid.value =
        value.isNotEmpty && value.length >= 6; // Minimum 6 characters
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    showPassword.value = !showPassword.value;
    update();
  }

  Future<void> loginData() async {
    Loader.show();
    FirebaseSignIn_UseCase firebaseSignIn_UseCase = initController(
      () => FirebaseSignIn_UseCase(Get.find()),
    );

    final Either<AppError, UserCredential> userdata =
        await firebaseSignIn_UseCase(
          FirebaseAuthModel(
            "${phone.value}@link.com",
            textEditingControllerPassword.text.isEmpty
                ? phone.value
                : textEditingControllerPassword.text,
          ),
        );
    userdata.fold(
      (l) {
        Loader.showError(l.messege);
      },
      (r) {
        Loader.showSuccess("تم تسجيل الدخول بنجاح");

        getUserData(r.user?.uid ?? "");
        update();
      },
    );
  }

  Future<void> SaveUserToFirebaseRealtime(String uid) async {
    LocalUser userClient = LocalUser(
      uid: uid,
      key: const Uuid().v4(),
      phone: phone.value,
      identifier: "${phone.value}@link.com",
      isCompleteProfile: 0,
      fcmToken: await ConstantsData.firebaseToken(),
      userType: UserType.admin,
      password: password.value,
    );

    AuthenticationService().addClientsData(
      userclient: userClient,
      voidCallBack: (model) {
        Loader.dismiss();
        userClient.saveLocal(
          saveCallback: () async {
            if (userClient.userType == UserType.assistant ||
                userClient.userType == UserType.doctor) {
              Get.offAllNamed(syncView);
            } else if (userClient.userType == UserType.pharmacy) {
              openAssistantApp();
            } else {
              _updateClientsSyncStatus();
              Get.offAllNamed(mainpage);
            }
            await NotificationService().subscribeAfterLogin();
            NotificationService().printCurrentTopic();
          },
        );
        update();
      },
    );
  }

  Future<void> _updateClientsSyncStatus() async {
    final ref = FirebaseDatabase.instance.ref("sync_meta/clients");

    await ref.update({
      "last_add_data_timestamp": DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> openAssistantApp() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'medicines.db');

    final exists = await databaseExists(path);

    if (!exists) {
      Get.offAll(() => const SyncMedicineView(),
          binding: SyncMedicineBinding());
      return;
    }

    final db = await openDatabase(path);
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM medicines'),
    );
    if (count == null || count == 0) {
      // 🟡 DB موجودة لكن فاضية
      Get.offAll(() => const SyncMedicineView(),
          binding: SyncMedicineBinding());
    } else {
      // 🟢 طبيعي
      Get.offAll(() => const MainPage());
    }
  }

  Future<void> getUserData(String uid) async {
    AuthenticationService().getSingleClientsData(
      filrebaseFilter: FirebaseFilter(equalTo: uid, orderBy: "token"),
      voidCallBack: (user) async {
        Loader.dismiss();

        final newToken = await ConstantsData.firebaseToken();
        //  final newToken = "await ConstantsData.firebaseToken()";

        if (user == null) {
          // ✅ No user found → create new in Firebase Realtime
          SaveUserToFirebaseRealtime(uid);
        } else {
          // 🔹 Check if FCM token is missing or outdated → Update it
          if (user.fcmToken == null || user.fcmToken != newToken) {
            final updatedUser = user.copyWith(fcmToken: newToken);

            await AuthenticationService().updateClientsData(
              userclient: updatedUser,
              voidCallBack: (status) {
                if (status == ResponseStatus.success) {
                } else {}
              },
            );

            // 🧠 Update the in-memory user with the new token
            user = updatedUser;
          }

          // ✅ Save locally after update
          user.saveLocal(
            saveCallback: () async {
              if (user?.userType == UserType.assistant ||
                  user?.userType == UserType.doctor) {
                Get.offAllNamed(syncView);
              } else if (user?.userType == UserType.pharmacy) {
                openAssistantApp();
              } else {
                _updateClientsSyncStatus();
                Get.offAllNamed(mainpage);
              }
              await NotificationService().subscribeAfterLogin();
              NotificationService().printCurrentTopic();
            },
          );
        }

        update();
      },
    );
  }
}
