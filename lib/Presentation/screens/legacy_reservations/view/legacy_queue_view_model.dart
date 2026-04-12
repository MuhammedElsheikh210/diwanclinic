import 'package:intl/intl.dart';
import '../../../../index/index_main.dart';

class LegacyQueueViewModel extends GetxController {
  final LegacyQueueService service = LegacyQueueService();

  List<LegacyQueueModel?>? list;

  /// 👨‍⚕️ Doctors (Center Mode)
  List<LocalUser?>? centerDoctors;
  LocalUser? selectedDoctor;
  bool isLoadingDoctors = false;

  bool get isCenterMode => false;

  /// 🕒 Shift
  List<GenericListModel>? shiftDropdownItems;
  GenericListModel? selectedShift;

  /// 📅 Date
  DateTime selectedDate = DateTime.now();

  String get formattedDate => DateFormat('dd-MM-yyyy').format(selectedDate);

  // ------------------------------------------------------------
  @override
  void onInit() {
    super.onInit();

    if (isCenterMode) {
      loadDoctorsOfCenter();
    } else {
      getData();
    }
  }

  // ------------------------------------------------------------
  // 👨‍⚕️ LOAD DOCTORS
  // ------------------------------------------------------------
  Future<void> loadDoctorsOfCenter() async {
    // final centerKey = LocalUser().getUserData().medicalCenterKey;
    // if (centerKey == null) return;
    //
    // isLoadingDoctors = true;
    // update();
    //
    // AuthenticationService().getClientsData(
    //   query: SQLiteQueryParams(
    //     where: "medicalCenterKey = ? AND userType = ?",
    //     whereArgs: [centerKey, "doctor"],
    //   ),
    //   voidCallBack: (data) async {
    //     centerDoctors = data;
    //
    //     if (data.isNotEmpty) {
    //       selectedDoctor = data.first;
    //
    //       /// 🔥 load data based on doctor
    //       getData();
    //     }
    //
    //     isLoadingDoctors = false;
    //     update();
    //   },
    // );
  }

  // ------------------------------------------------------------
  // 📅 Change Date
  // ------------------------------------------------------------
  void onDateChanged(DateTime date) {
    selectedDate = date;
    getData();
    update();
  }

  // ------------------------------------------------------------
  // 📥 GET DATA (🔥 IMPORTANT FIX)
  // ------------------------------------------------------------
  void getData() {
    final currentUser = Get.find<UserSession>().user;

    if (currentUser == null) {
      debugPrint("❌ User not found in session");
      return;
    }

    final baseUser = currentUser.user;

    String? doctorKey;

    // ✅ Doctor
    if (baseUser is DoctorUser) {
      doctorKey = baseUser.uid;
    }
    // ✅ Assistant
    else if (baseUser is AssistantUser) {
      doctorKey = baseUser.doctorKey;
    }

    final clinicKey = currentUser.clinicKey;

    service.getLegacyQueueByDateData(
      doctorUid: isCenterMode ? selectedDoctor?.uid : doctorKey,

      firebaseFilter:
          isCenterMode
              ? FirebaseFilter()
              : FirebaseFilter(orderBy: "clinic_key", equalTo: clinicKey),

      voidCallBack: (data) {
        list = data;
        update();
      },
    );
  }

  // ------------------------------------------------------------
  void deleteItem(LegacyQueueModel model) {
    service.deleteLegacyQueueData(
      date: model.date ?? "",
      key: model.key ?? "",
      isPatient: false,
      doctorUid: isCenterMode ? selectedDoctor?.uid : null,
      // ✅ مهم
      voidCallBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          getData();
        }
      },
    );
  }

  // ------------------------------------------------------------
  // 🔄 CHANGE DOCTOR
  // ------------------------------------------------------------
  Future<void> changeDoctor(LocalUser doctor) async {
    selectedDoctor = doctor;

    update();

    getData();
  }
}
