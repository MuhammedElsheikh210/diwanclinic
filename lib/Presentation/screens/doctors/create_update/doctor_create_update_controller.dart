import 'dart:io';
import '../../../../../index/index_main.dart';

class CreateDoctorViewModel extends GetxController {
  final String specializeKey;
  final String specializeName;
  final String? medicalCenterKey;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController facebookController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();
  final TextEditingController tiktokController = TextEditingController();
  final TextEditingController specializationNameController =
      TextEditingController();
  final TextEditingController qualificationsController =
      TextEditingController();

  File? profileImageFile;
  File? coverImageFile;

  int remoteReservationAbility = 1;

  bool isUpdate = false;
  LocalUser? existingDoctor;

  /// 🧠 NEW → Specializations
  List<CategoryEntity?>? specializations;
  CategoryEntity? selectedSpecialization;

  CreateDoctorViewModel({
    required this.specializeKey,
    required this.specializeName,
    this.medicalCenterKey,
  });

  final _picker = ImagePicker();

  // ================== INIT ==================

  @override
  void onInit() {
    super.onInit();

    nameController.addListener(() => update());
    phoneController.addListener(() => update());

    /// If opened from specialization screen → preselect
    if (specializeKey.isNotEmpty) {
      selectedSpecialization = CategoryEntity(
        key: specializeKey,
        name: specializeName,
      );
    }

    /// Load specializations if opened from medical center
    if (medicalCenterKey != null) {
      getSpecializations();
    }

    if (existingDoctor != null) {
      remoteReservationAbility =
          existingDoctor?.remote_reservation_ability ?? 0;
    }
  }

  // ================== SPECIALIZATIONS ==================

  void getSpecializations() {
    CategoryService().getAllCategoriesData(
      voidCallBack: (data) {
        specializations = data;
        update();
      },
    );
  }

  void selectSpecialization(CategoryEntity? value) {
    selectedSpecialization = value;
    specializationNameController.text = value?.name ?? "";
    update();
  }

  // ================== IMAGE PICKERS ==================

  Future<void> pickProfileImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      profileImageFile = File(picked.path);
      update();
    }
  }

  Future<void> pickCoverImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      coverImageFile = File(picked.path);
      update();
    }
  }

  Future<String?> _uploadImage(File file, String folder) async {
    try {
      final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
      final ref = FirebaseStorage.instance.ref().child(
        "doctors/$folder/$fileName",
      );
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint("❌ Failed to upload image: $e");
      return null;
    }
  }

  // ================== SETTINGS ==================

  void setRemoteReservationAbility(bool value) {
    remoteReservationAbility = value ? 1 : 0;
    update();
  }

  // ================== SAVE ==================

  Future<void> saveDoctor() async {
    if (!validateStep()) {
      Loader.showError("يرجى إدخال جميع البيانات بشكل صحيح");
      return;
    }

    Loader.show();

    String? profileUrl;
    String? coverUrl;

    if (profileImageFile != null) {
      profileUrl = await _uploadImage(profileImageFile!, "profile");
    }
    if (coverImageFile != null) {
      coverUrl = await _uploadImage(coverImageFile!, "cover");
    }

    if (isUpdate && existingDoctor != null) {
      _updateDoctor(existingDoctor!, profileUrl, coverUrl);
    } else {
      await _createDoctorAccount(profileUrl, coverUrl);
    }
  }

  void _updateDoctor(LocalUser doctor, String? profileUrl, String? coverUrl) {
    final updatedDoctor = doctor.copyWith(
      name: nameController.text,
      doctorQualifications: qualificationsController.text,
      phone: phoneController.text,
      whatsAppPhone: whatsappController.text,
      facebookLink: facebookController.text,
      instagramLink: instagramController.text,
      tiktokLink: tiktokController.text,
      specializationName: selectedSpecialization?.name,
      specialize_key: selectedSpecialization?.key,
      profileImage: profileUrl ?? doctor.profileImage,
      coverImage: coverUrl ?? doctor.coverImage,
      remote_reservation_ability: remoteReservationAbility,
      medicalCenterKey: medicalCenterKey ?? doctor.medicalCenterKey,
    );

    AuthenticationService().updateClientsData(
      userclient: updatedDoctor,
      voidCallBack: (_) {
        Loader.dismiss();
        Loader.showSuccess("تم تحديث الطبيب بنجاح");
        refreshListView();
      },
    );
  }

  Future<void> _createDoctorAccount(
    String? profileUrl,
    String? coverUrl,
  ) async {
    final email = "${phoneController.text}@link.com";
    final password = phoneController.text;

    try {
      final userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCred.user?.uid ?? "";

      final doctor = LocalUser(
        uid: uid,
        key: const Uuid().v4(),
        phone: phoneController.text,
        doctorQualifications: qualificationsController.text,
        whatsAppPhone: whatsappController.text,
        facebookLink: facebookController.text,
        instagramLink: instagramController.text,
        tiktokLink: tiktokController.text,

        specializationName: selectedSpecialization?.name,
        specialize_key: selectedSpecialization?.key,
        identifier: email,
        password: password,
        userType: UserType.doctor,
        medicalCenterKey: medicalCenterKey,
        profileImage: profileUrl,
        coverImage: coverUrl,
        isCompleteProfile: 0,
        name: nameController.text,
        remote_reservation_ability: remoteReservationAbility,
      );

      AuthenticationService().addClientsData(
        userclient: doctor,
        voidCallBack: (_) {
          Loader.dismiss();
          Loader.showSuccess("تم إضافة الطبيب بنجاح");
          refreshListView();
        },
      );
    } on FirebaseAuthException catch (e) {
      Loader.showError("فشل إنشاء الحساب: ${e.message}");
    }
  }

  // ================== REFRESH ==================

  void refreshListView() {
    if (medicalCenterKey != null && medicalCenterKey!.isNotEmpty) {
      final doctorVM = initController(
        () => DoctorViewModel.byCenter(medicalCenterKey!),
      );
      doctorVM.getDoctorsByCenter(medicalCenterKey!);
      doctorVM.update();
    } else {
      final doctorVM = initController(
        () => DoctorViewModel(specializeKey: specializeKey),
      );
      doctorVM.getData();
      doctorVM.update();
    }
    Get.back();
  }

  // ================== VALIDATION ==================

  bool validateStep() {
    return nameController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        selectedSpecialization != null;
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    qualificationsController.dispose();
    whatsappController.dispose();
    facebookController.dispose();
    instagramController.dispose();
    tiktokController.dispose();
    specializationNameController.dispose();
    super.dispose();
  }
}
