import 'dart:io';

import '../../../../../index/index_main.dart';

class PatientProfileAllHistoryViewModel extends GetxController {
  // ─────────────────────────────────────────────
  // 👤 Patient Info
  // ─────────────────────────────────────────────
  LocalUser? patientModel;
  final Map<String, MedicalRecordModel> reservationMedicalRecords = {};

  /// ─────────────────────────────────────────────
  /// 🔎 Get Medical Record By Reservation Key
  /// ─────────────────────────────────────────────
  MedicalRecordModel? getMedicalRecordByReservationKey(String? reservationKey) {
    if (reservationKey == null) {
      return null;
    }

    return reservationMedicalRecords[reservationKey];
  }

  late TextEditingController revisitDateController;
  late TextEditingController notesController;

  ReservationModel? get currentReservation {
    if (reservations.isEmpty) {
      return null;
    }

    return reservations.first;
  }

  bool get canCompleteCurrentReservation {
    final status = currentReservation?.status;
    print("status is ${status}");

    return status == "approved" || status == "in_progress";
  }

  // ─────────────────────────────────────────────
  // ⌨️ Focus Nodes
  // ─────────────────────────────────────────────
  final HandleKeyboardService keyboardService = HandleKeyboardService();

  late List<String> keyboardKeys;

  final List<XFile> selectedImages = [];

  // ─────────────────────────────────────────────
  // 📅 Reservations
  // ─────────────────────────────────────────────
  List<ReservationModel> reservations = [];

  // ─────────────────────────────────────────────
  // 🩺 Medical Categories
  // ─────────────────────────────────────────────
  List<CategoryEntity?> medicalCategories = [];

  // ─────────────────────────────────────────────
  // ✅ Selected Category
  // ─────────────────────────────────────────────
  CategoryEntity? selectedCategory;

  // ─────────────────────────────────────────────
  // 🧩 Dynamic Properties
  // ─────────────────────────────────────────────
  List<MedicalRecordPropertyModel?> properties = [];

  // ─────────────────────────────────────────────
  // 📝 Dynamic Controllers
  // key => propertyKey
  // ─────────────────────────────────────────────
  final Map<String, TextEditingController> propertyControllers = {};

  @override
  void onInit() {
    super.onInit();

    revisitDateController = TextEditingController();
    notesController = TextEditingController();

    keyboardKeys = keyboardService.generateKeys('MedicalRecordForm', 50);
  }

  // ─────────────────────────────────────────────
  // 📥 Fetch Patient + Reservations + Categories
  // ─────────────────────────────────────────────
  Future<void> getData(String patientKey) async {
    try {
      Loader.show();

      await AuthenticationService().getClientsData(
        query: SQLiteQueryParams(
          where: "uid = ?",
          whereArgs: [patientKey],
          limit: 1,
        ),

        voidCallBack: (users) async {
          if (users.isEmpty || users.first == null) {
            Loader.dismiss();

            Loader.showError("لم يتم العثور على بيانات العميل");

            return;
          }

          patientModel = users.first!;

          /// Reservations
          await _loadLocalReservations(patientKey);

          /// Categories
          await getMedicalCategories();

          Loader.dismiss();

          update();
        },
      );
    } catch (e) {
      Loader.dismiss();

      Loader.showError("حدث خطأ أثناء تحميل البيانات");
    }
  }

  Future<void> completeReservation({
    required ReservationModel reservation,
  }) async {
    try {
      Loader.show();

      /// =========================================
      /// 1- SAVE MEDICAL RECORD
      /// =========================================
      await saveMedicalRecord(reservation: reservation);

      /// =========================================
      /// 2- UPDATE STATUS
      /// =========================================
      reservation.status = ReservationStatus.completed.value;

      await updateReservationStatus(reservation);

      /// =========================================
      /// 3- WHATSAPP
      /// =========================================
      await WhatsAppStatusMessageService.sendStatusWhatsAppMessage(
        reservation: reservation,
        clinic: null,
        newStatus: ReservationStatus.completed,
      );

      /// =========================================
      /// 4- LOCAL UPDATE
      /// =========================================
      final index = reservations.indexWhere((e) => e.key == reservation.key);

      if (index != -1) {
        reservations[index] = reservation;
      }

      Loader.dismiss();

      Loader.showSuccess("تم إنهاء الكشف بنجاح");
      clearMedicalForm();

      Get.back();

      update();
    } catch (e) {
      Loader.dismiss();

      Loader.showError("حدث خطأ أثناء إنهاء الكشف");
    }
  }

  Future<void> updateReservationStatus(ReservationModel reservation) async {
    final completer = Completer<void>();

    await ReservationService().updateReservationData(
      reservation: reservation,

      voidCallBack: (status) {
        if (status == ResponseStatus.success) {
          completer.complete();
        } else {
          completer.completeError("failed");
        }
      },
    );

    return completer.future;
  }

  // ─────────────────────────────────────────────
  // 📡 Reservations
  // ─────────────────────────────────────────────
  Future<void> _loadLocalReservations(String patientKey) async {
    await ReservationService().getReservationsData(
      query: SQLiteQueryParams(
        is_filtered: true,
        where: "patient_uid = ?",
        whereArgs: [patientKey],
        orderBy: "created_at DESC",
      ),

      voidCallBack: (list) {
        reservations = list.whereType<ReservationModel>().toList();

        reservations.sort((a, b) {
          final aDate = a.createdAt ?? 0;

          final bDate = b.createdAt ?? 0;

          return bDate.compareTo(aDate);
        });
        loadMedicalRecords();

        update();
      },
    );
  }

  Future<void> loadMedicalRecords() async {
    try {
      reservationMedicalRecords.clear();

      for (final reservation in reservations) {
        final reservationKey = reservation.key;

        if (reservationKey == null) {
          continue;
        }

        await MedicalRecordService().getMedicalRecordsData(
          data: {},
          firebaseFilter: FirebaseFilter(
            orderBy: "reservation_key",
            equalTo: reservationKey,
          ),

          query: SQLiteQueryParams(),

          voidCallBack: (data) {
            if (data.isEmpty || data.first == null) {
              return;
            }

            reservationMedicalRecords[reservationKey] = data.first!;
          },
        );
      }

      print("MEDICAL RECORDS => ${reservationMedicalRecords.length}");

      update();
    } catch (e) {
      print("LOAD MEDICAL RECORDS ERROR => $e");
    }
  }

  // ─────────────────────────────────────────────
  // 🩺 Get Medical Categories
  // ─────────────────────────────────────────────
  Future<void> getMedicalCategories() async {
    await CategoryService().getAllCategoriesData(
      data: {
        "categoryType": Strings.medicalRecords,
      },

      filterParams: SQLiteQueryParams(),

      voidCallBack: (data) async {
        medicalCategories = data;

        /// ✅ If categories exist
        if (medicalCategories.isNotEmpty &&
            medicalCategories.first != null) {
          await onSelectCategory(
            medicalCategories.first,
          );
        }

        /// ✅ No categories → load all properties
        else {
          await getAllProperties();
        }

        update();
      },
    );
  }

  Future<void> getAllProperties() async {
    await MedicalRecordPropertyService()
        .getMedicalRecordPropertiesData(
      data: {},

      firebaseFilter: FirebaseFilter(),

      query: SQLiteQueryParams(),

      voidCallBack: (data) {
        properties = data;

        propertyControllers.clear();

        for (final property in properties) {
          if (property?.key != null) {
            propertyControllers[property!.key!] =
                TextEditingController();
          }
        }

        update();
      },
    );
  }  // ─────────────────────────────────────────────
  // 🧾 Select Category
  // ─────────────────────────────────────────────
  Future<void> onSelectCategory(CategoryEntity? category) async {
    selectedCategory = category;

    /// Clear old data
    properties.clear();

    propertyControllers.clear();

    update();

    if (category == null) {
      return;
    }

    await getProperties(category.key ?? "");
  }

  // ─────────────────────────────────────────────
  // 🧩 Get Properties
  // ─────────────────────────────────────────────
  Future<void> getProperties(String categoryKey) async {
    await MedicalRecordPropertyService().getMedicalRecordPropertiesData(
      data: {"category_key": categoryKey},

      firebaseFilter: FirebaseFilter(
        orderBy: "category_key",
        equalTo: categoryKey,
      ),

      query: SQLiteQueryParams(),

      voidCallBack: (data) {
        properties = data;

        /// Create Controllers
        for (final property in properties) {
          if (property?.key != null) {
            propertyControllers[property!.key!] = TextEditingController();
          }
        }

        print("PROPERTIES => ${properties.map((e) => e?.toJson()).toList()}");

        update();
      },
    );
  }

  // ─────────────────────────────────────────────
  // 📝 Get Controller
  // ─────────────────────────────────────────────
  TextEditingController? getPropertyController(String? key) {
    if (key == null) return null;

    return propertyControllers[key];
  }

  // ─────────────────────────────────────────────
  // 💾 Save Medical Record
  // ─────────────────────────────────────────────
  Future<void> saveMedicalRecord({
    required ReservationModel reservation,
  }) async {
    if (selectedCategory == null) {
      Loader.showError("من فضلك اختر التصنيف");

      return;
    }

    final user = Get.find<UserSession>().user?.user;

    if (user?.uid == null) {
      Loader.showError("لم يتم العثور على بيانات الطبيب");

      return;
    }

    try {
      /// =========================================
      /// PREPARE PROPERTIES
      /// =========================================
      final List<MedicalRecordPropertyModel> filledProperties = [];

      for (final property in properties) {
        if (property == null) continue;

        final controller = propertyControllers[property.key];

        final rawValue = controller?.text.trim() ?? "";

        /// skip empty
        if (rawValue.isEmpty) {
          continue;
        }

        dynamic finalValue = rawValue;

        /// ✅ NUMBER
        if (property.type == "number") {
          final parsedNumber = double.tryParse(rawValue);

          if (parsedNumber == null) {
            Loader.showError("قيمة ${property.label ?? ""} يجب أن تكون رقم");

            return;
          }

          finalValue = parsedNumber;
        }
        /// ✅ DATE
        else if (property.type == "date") {
          finalValue = rawValue;
        }
        /// ✅ TEXT
        else {
          finalValue = rawValue;
        }

        filledProperties.add(
          MedicalRecordPropertyModel(
            key: property.key,

            categoryKey: property.categoryKey,

            label: property.label,

            type: property.type,

            value: finalValue,
          ),
        );
      }

      /// =========================================
      /// UPLOAD IMAGES
      /// =========================================
      final List<String> uploadedPhotos = await uploadMedicalImages(
        reservation,
      );

      /// =========================================
      /// CREATE RECORD
      /// =========================================
      final medicalRecord = MedicalRecordModel(
        key: const Uuid().v4(),

        patientKey: patientModel?.uid,

        doctorKey: user?.uid,

        reservationKey: reservation.key,

        categoryKey: selectedCategory?.key,

        categoryName: selectedCategory?.name,

        createAt: DateTime.now().toIso8601String(),

        revisitDate:
            revisitDateController.text.trim().isEmpty
                ? null
                : revisitDateController.text.trim(),

        notes:
            notesController.text.trim().isEmpty
                ? null
                : notesController.text.trim(),

        /// ✅ REAL FIREBASE URLS
        photos: uploadedPhotos,

        status: "active",

        properties: filledProperties,
      );

      /// =========================================
      /// SAVE
      /// =========================================
      await MedicalRecordService().addMedicalRecordData(
        medicalRecord: medicalRecord,

        voidCallBack: (status) {
          if (status != ResponseStatus.success) {
            Loader.showError("حدث خطأ أثناء حفظ الكشف");
          }
        },
      );
    } catch (e) {
      print("SAVE MEDICAL RECORD ERROR => $e");

      Loader.showError("حدث خطأ أثناء حفظ الكشف");
    }
  }

  // ─────────────────────────────────────────────
  // 🧹 Clear All
  // ─────────────────────────────────────────────
  void clearData() {
    patientModel = null;

    reservations.clear();

    medicalCategories.clear();

    clearMedicalForm();

    update();
  }

  void clearMedicalForm() {
    selectedCategory = null;

    properties.clear();

    revisitDateController.clear();
    notesController.clear();

    selectedImages.clear();

    for (final controller in propertyControllers.values) {
      controller.dispose();
    }

    propertyControllers.clear();

    update();
  }

  Future<List<String>> uploadMedicalImages(ReservationModel reservation) async {
    final List<String> uploadedUrls = [];

    if (selectedImages.isEmpty) {
      return uploadedUrls;
    }

    try {
      for (int i = 0; i < selectedImages.length; i++) {
        final image = selectedImages[i];

        final file = File(image.path);

        final ref = FirebaseStorage.instance.ref(
          "medical_records/${reservation.key}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg",
        );

        final uploadTask = ref.putFile(file);

        await uploadTask;

        final url = await ref.getDownloadURL();

        uploadedUrls.add(url);
      }

      return uploadedUrls;
    } catch (e) {
      print("UPLOAD MEDICAL IMAGES ERROR => $e");

      return [];
    }
  }

  @override
  void dispose() {
    revisitDateController.dispose();
    notesController.dispose();

    for (final controller in propertyControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }
}
