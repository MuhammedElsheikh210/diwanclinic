import '../../../../../index/index_main.dart';

class CreateAssistantViewModel extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  List<ClinicModel?>? listClinics;
  ClinicModel? selectedClinic;

  bool isUpdate = false;
  LocalUser? existingAssistant;

  final String? medicalCenterKey;

  CreateAssistantViewModel({this.medicalCenterKey});

  // ============================================================
  // 🧠 CURRENT USER
  // ============================================================

  BaseUser? get _user => Get.find<UserSession>().user?.user;

  // ============================================================
  // 🚀 INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    nameController.addListener(update);
    phoneController.addListener(update);

    getClinicsData();
  }

  // ============================================================
  // 💾 SAVE
  // ============================================================

  void saveAssistant() async {
    if (!validateStep()) {
      Loader.showError("يرجى إدخال جميع البيانات بشكل صحيح");
      return;
    }

    if (isUpdate && existingAssistant != null) {
      _updateAssistant(existingAssistant!);
    } else {
      await _createAssistantAccount();
    }
  }

  // ============================================================
  // ✏️ UPDATE
  // ============================================================

  void _updateAssistant(LocalUser assistant) {
    Loader.show();

    final base = assistant.asAssistant;

    if (base == null) return;

    final updatedAssistantUser = AssistantUser(
      uid: base.uid,
      createdAt: base.createdAt,
      userType: base.userType,
      isProfileCompleted: base.isProfileCompleted,
      fcmToken: base.fcmToken,
      appVersion: base.appVersion,
      email: base.email,
      password: phoneController.text,

      name: nameController.text,
      phone: phoneController.text,
      address: base.address,
      profileImage: base.profileImage,

      clinicKey: selectedClinic?.key,
      doctorKey: base.doctorKey,
      transferNumber: base.transferNumber,
      isInstaPay: base.isInstaPay,
    );

    final updatedAssistant = LocalUser(updatedAssistantUser);

    AuthenticationService().updateClientsData(
      userclient: updatedAssistant,
      voidCallBack: (_) {
        Loader.dismiss();
        Loader.showSuccess("تم تحديث المساعد بنجاح");
        refreshListView();
      },
    );
  }

  // ============================================================
  // ➕ CREATE ACCOUNT
  // ============================================================

  Future<void> _createAssistantAccount() async {
    Loader.show();

    final email = "${phoneController.text}@link.com";
    final password = phoneController.text;

    try {
      final userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCred.user?.uid;

      if (uid == null || uid.isEmpty) {
        throw Exception("❌ UID creation failed");
      }

      final currentUser = _user;

      String? doctorKey;
      String? transferNumber;
      bool isInstaPay = false;

      if (currentUser is DoctorUser) {
        doctorKey = currentUser.uid;
      }

      if (currentUser is AssistantUser) {
        doctorKey = currentUser.doctorKey;
      }

      final assistantUser = AssistantUser(
        uid: uid,
        phone: phoneController.text,
        name: nameController.text,
        email: email,
        password: password,
        userType: UserType.assistant,
        isProfileCompleted: true,

        clinicKey: selectedClinic?.key,
        doctorKey: doctorKey,
        transferNumber: transferNumber,
        isInstaPay: isInstaPay,
      );

      final userClient = LocalUser(assistantUser);

      _saveAssistantToClients(userClient);
    } on FirebaseAuthException catch (e) {
      Loader.dismiss();
      Loader.showError("فشل إنشاء الحساب: ${e.message}");
    } catch (e) {
      Loader.dismiss();
      Loader.showError("حدث خطأ: $e");
    }
  }

  // ============================================================
  // 💾 SAVE TO DB
  // ============================================================

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

  // ============================================================
  // 🏥 GET CLINICS
  // ============================================================

  void getClinicsData() {
    final user = _user;

    String? doctorKey;

    if (user is DoctorUser) {
      doctorKey = user.uid;
    } else if (user is AssistantUser) {
      doctorKey = user.doctorKey;
    }

    if (doctorKey == null || doctorKey.isEmpty) {
      debugPrint("❌ doctorKey missing → skip clinics");
      return;
    }

    ClinicService().getClinicsData(
      data: {},
      doctorKey: doctorKey,
      filrebaseFilter: FirebaseFilter(),
      query: SQLiteQueryParams(
        is_filtered: true,
        where: "doctor_key = ?",
        whereArgs: [doctorKey],
      ),
      isFiltered: true,
      voidCallBack: (data) {
        Loader.dismiss();

        listClinics = data;

        if (listClinics != null &&
            listClinics!.isNotEmpty &&
            selectedClinic == null) {
          selectedClinic = listClinics!.first;
        }

        update();
      },
    );
  }

  // ============================================================
  // 🔄 REFRESH
  // ============================================================

  void refreshListView() {
    final assistantVM = initController(() => AssistantViewModel());
    assistantVM.getData();
    assistantVM.update();
    Get.back();
  }

  // ============================================================
  // ✅ VALIDATION
  // ============================================================

  bool validateStep() {
    return nameController.text.isNotEmpty && phoneController.text.isNotEmpty;
  }

  // ============================================================
  // 🛑 DISPOSE
  // ============================================================

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
