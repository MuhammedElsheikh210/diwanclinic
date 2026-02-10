import 'package:diwanclinic/Presentation/parentControllers/archive_patient_service.dart';

import '../../../../../index/index_main.dart';

class ArchivePatientViewModel extends GetxController {
  List<ArchivePatientModel>? archives;
  bool isLoading = true;

  @override
  void onInit() {
    super.onInit();
    getData();
  }

  /// 📥 Load archive patients
  void getData() {
    isLoading = true;
    update();

    ArchivePatientService().getArchivePatientsData(
      data: {},
      voidCallBack: (data) {
        archives = data;
        isLoading = false;
        update();
      },
    );
  }

  /// 🗑 Delete
  void deleteArchive(String archiveId) {
    ArchivePatientService().deleteArchivePatientData(
      archiveId: archiveId,
      voidCallBack: (_) => getData(),
    );
  }
}
