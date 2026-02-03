// ignore_for_file: avoid_renaming_method_parameters

import '../../index/index_main.dart';

class PatientService {
  final PatientUseCases useCase = initController(
        () => PatientUseCases(Get.find()),
  );

  Future<void> addPatientData({
    required PatientModel patient,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.addPatient(patient);
    result.fold(
          (l) => voidCallBack(ResponseStatus.error),
          (r) => voidCallBack(ResponseStatus.success),
    );
  }

  Future<void> updatePatientData({
    required PatientModel patient,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.updatePatient(patient);
    result.fold(
          (l) => voidCallBack(ResponseStatus.error),
          (r) => voidCallBack(ResponseStatus.success),
    );
  }

  Future<void> deletePatientData({
    required String patientKey,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    Loader.show();
    final result = await useCase.deletePatient(patientKey);
    result.fold(
          (l) => voidCallBack(ResponseStatus.error),
          (r) => voidCallBack(ResponseStatus.success),
    );
  }

  Future<void> getPatientsData({
    required Map<String, dynamic> data,
    required SQLiteQueryParams query,
    bool? isFiltered,
    required Function(List<PatientModel?>) voidCallBack,
  }) async {
    //Loader.show();
    final result = await useCase.getPatients(data, query, isFiltered);
    result.fold(
          (l) => Loader.showError("Something went wrong"),
          (r) => voidCallBack(r),
    );
  }
}
