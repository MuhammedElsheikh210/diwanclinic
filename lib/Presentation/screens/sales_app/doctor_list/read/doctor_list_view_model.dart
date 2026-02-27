import 'package:diwanclinic/Presentation/parentControllers/doctor_list_service.dart';
import '../../../../../index/index_main.dart';

class DoctorListViewModel extends GetxController {
  /// 🔹 Original Data
  List<DoctorListModel>? listDoctors;

  /// 🔹 Filtered Data
  List<DoctorListModel> filteredDoctors = [];

  /// 🔹 Filter Values
  SpecializationModel? selectedFilterSpecialization;
  String? selectedFilterClass;

  final List<SpecializationModel> specializations =
      SpecializationMapper.all;

  final List<String> doctorClasses = const ["A", "B", "C"];

  /// 🔹 Total Count
  int get totalDoctors => listDoctors?.length ?? 0;

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  /// ================= GET DATA =================
  void getData() {
    DoctorListService().getDoctorListData(
      query: {},
      voidCallBack: (data) {
        listDoctors = data;
        filteredDoctors = List.from(data);
        update();
      },
    );
  }

  /// ================= APPLY FILTER =================
  void applyFilter() {
    if (listDoctors == null) return;

    filteredDoctors = listDoctors!.where((doctor) {
      final matchSpecialization =
          selectedFilterSpecialization == null ||
              doctor.specialization ==
                  selectedFilterSpecialization!.key;

      final matchClass =
          selectedFilterClass == null ||
              doctor.doctorClass == selectedFilterClass;

      return matchSpecialization && matchClass;
    }).toList();

    update();
  }

  /// ================= CLEAR FILTER =================
  void clearFilter() {
    selectedFilterSpecialization = null;
    selectedFilterClass = null;
    filteredDoctors = List.from(listDoctors ?? []);
    update();
  }

  /// ================= DELETE =================
  void deleteDoctor(DoctorListModel doctor) {
    DoctorListService().deleteDoctorData(
      doctorKey: doctor.key ?? "",
      voidCallBack: (_) {
        getData();
        Loader.showSuccess("تم حذف الدكتور");
      },
    );
  }
}