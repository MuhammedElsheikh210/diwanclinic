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

    if (specializeKey.isNotEmpty) {
      selectedSpecialization = CategoryEntity(
        key: specializeKey,
        name: specializeName,
      );
    }

    if (medicalCenterKey != null) {
      getSpecializations();
    }

    if (existingDoctor != null && existingDoctor!.isDoctor) {
      remoteReservationAbility =
          existingDoctor!.asDoctor?.remoteReservationAbility ?? 0;
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
      final ref = FirebaseStorage.instance
          .ref()
          .child("doctors/$folder/$fileName");

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

  // ================== UPDATE ==================

  void _updateDoctor(LocalUser doctor, String? profileUrl, String? coverUrl) {
    final base = doctor.asDoctor;

    if (base == null) return;

    final updatedDoctorUser = DoctorUser(
      uid: base.uid,
      createdAt: base.createdAt,
      userType: base.userType,
      isProfileCompleted: base.isProfileCompleted,
      fcmToken: base.fcmToken,
      appVersion: base.appVersion,
      identifier: base.identifier,
      password: base.password,

      name: nameController.text,
      phone: phoneController.text,
      profileImage: profileUrl ?? base.profileImage,
      address: base.address,

      doctorQualifications: qualificationsController.text,
      specializationName: selectedSpecialization?.name,
      specializeKey: selectedSpecialization?.key,

      facebookLink: facebookController.text,
      instagramLink: instagramController.text,
      tiktokLink: tiktokController.text,

      totalRate: base.totalRate,
      numberOfRates: base.numberOfRates,
    );

    final updatedDoctor = LocalUser(updatedDoctorUser);

    AuthenticationService().updateClientsData(
      userclient: updatedDoctor,
      voidCallBack: (_) {
        Loader.dismiss();
        Loader.showSuccess("تم تحديث الطبيب بنجاح");
        refreshListView();
      },
    );
  }

  // ================== CREATE ==================

  Future<void> _createDoctorAccount(
      String? profileUrl,
      String? coverUrl,
      ) async {
    final email = "${phoneController.text}@link.com";
    final password = phoneController.text;

    try {
      final userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCred.user?.uid ?? "";

      final doctorUser = DoctorUser(
        uid: uid,
        phone: phoneController.text,
        name: nameController.text,
        identifier: email,
        password: password,
        userType: UserType.doctor,

        doctorQualifications: qualificationsController.text,
        specializationName: selectedSpecialization?.name,
        specializeKey: selectedSpecialization?.key,

        facebookLink: facebookController.text,
        instagramLink: instagramController.text,
        tiktokLink: tiktokController.text,

        profileImage: profileUrl,
      );

      final doctor = LocalUser(doctorUser);

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