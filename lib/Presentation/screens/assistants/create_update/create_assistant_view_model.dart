import 'package:diwanclinic/Data/Models/User_local/save_local_user.dart';
import 'package:diwanclinic/Data/Models/User_local/user_types_enums.dart';

import '../../../../../index/index_main.dart';

class CreateAssistantViewModel extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  List<ClinicModel?>? list_clinics;
  ClinicModel? selectedClinic;
  bool is_update = false;
  LocalUser? existingAssistant; // ✅ hold assistant being edited
  final String? medicalCenterKey;

  CreateAssistantViewModel({this.medicalCenterKey});

  @override
  void onInit() {
    super.onInit();
    nameController.addListener(() => update());
    phoneController.addListener(() => update());
    getClinicsData();
  }

  /// 🔹 Save assistant (either create or update)
  void saveAssistant() async {
    if (!validateStep()) {
      Loader.showError("يرجى إدخال جميع البيانات بشكل صحيح");
      return;
    }

    if (is_update && existingAssistant != null) {
      _updateAssistant(existingAssistant!);
    } else {
      await _createAssistantAccount();
    }
  }

  /// 🔹 Update existing assistant in clients node only
  void _updateAssistant(LocalUser assistant) {
    Loader.show();

    final updatedAssistant = assistant.copyWith(
      name: nameController.text,
      phone: phoneController.text,
      password: phoneController.text,
      medicalCenterKey: medicalCenterKey,
      clinicKey: selectedClinic?.key,
    );

    AuthenticationService().updateClientsData(
      userclient: updatedAssistant,
      voidCallBack: (_) {
        Loader.dismiss();
        Loader.showSuccess("تم تحديث المساعد بنجاح");
        refreshListView();
      },
    );
  }

  /// 🔹 Create Firebase Auth account for new assistant
  Future<void> _createAssistantAccount() async {
    Loader.show();

    final email = "${phoneController.text}@link.com";
    final password = phoneController.text;

    try {
      final userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCred.user?.uid ?? "";

      final userClient = LocalUser(
        uid: uid,
        key: const Uuid().v4(),
        phone: phoneController.text,
        identifier: email,
        password: password,
        medicalCenterKey: medicalCenterKey,
        userType: UserType.assistant,
        isCompleteProfile: 1,
        name: nameController.text,
      //  doctorKey:medicalCenterKey == null ? LocalUser().getUserData().uid : null,
      //  doctorName: medicalCenterKey == null ? LocalUser().getUserData().name : null,
        clinicKey: selectedClinic?.key,
      );

      _saveAssistantToClients(userClient);
    } on FirebaseAuthException catch (e) {
      Loader.showError("فشل إنشاء الحساب: ${e.message}");
    }
  }

  /// 🔹 Save new assistant in clients node
  void _saveAssistantToClients(LocalUser userClient) {
    AuthenticationService().addClientsData(
      userclient: userClient,
      voidCallBack: (_) {
        Loader.dismiss();
        Loader.showSuccess("تم إضافة المساعد بنجاح");
        refreshListView();
      },
    );
  }

  void getClinicsData() {
    String uid = LocalUser().getUserData().uid ?? "";

    ClinicService().getClinicsData(
      data: {},
      doctorKey: LocalUser().getUserData().doctorKey ?? "",

      filrebaseFilter: FirebaseFilter(),
      query: SQLiteQueryParams(
        is_filtered: true,
        where: "doctor_key = ?",
        whereArgs: [uid],
      ),
      isFiltered: true,
      voidCallBack: (data) {
        Loader.dismiss();
        list_clinics = data;

        if (list_clinics != null &&
            list_clinics!.isNotEmpty &&
            selectedClinic == null) {
          selectedClinic = list_clinics!.first;
        }

        update();
      },
    );
  }

  void refreshListView() {
    final assistantVM = initController(() => AssistantViewModel());
    assistantVM.getData();
    assistantVM.update();
    Get.back();
  }

  bool validateStep() {
    return nameController.text.isNotEmpty && phoneController.text.isNotEmpty;
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();

    super.dispose();
  }
}
