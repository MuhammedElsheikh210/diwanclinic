import 'package:diwanclinic/Data/data_source/patient_data_source.dart';

import '../../index/index_main.dart';

class PatientDataSourceRepoImpl extends PatientDataSourceRepo {
  final ClientSourceRepo _clientSourceRepo;
  final BaseSQLiteDataSourceRepo<PatientModel> _sqliteRepo;

  PatientDataSourceRepoImpl(this._clientSourceRepo)
    : _sqliteRepo = BaseSQLiteDataSourceRepo<PatientModel>(
        tableName: "patients",
        fromJson: (json) => PatientModel.fromJson(json),
        toJson: (model) => model.toJson(),
        getId: (model) => model.key,
        idColumn: "key",
      );

  @override
  Future<List<PatientModel?>> getPatients(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  ) async {
    try {
      final sqliteData = await _sqliteRepo.getAll(query: query);
      if (sqliteData.isNotEmpty || (sqliteData.isEmpty && isFiltered == true)) {
        return sqliteData;
      }
    } catch (_) {}

    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        "/${ApiConstatns.patients}.json",
        params: data,
      );

      List<PatientModel?> patientList = handleResponse<PatientModel>(
        response,
        (json) => PatientModel.fromJson(json),
      );

      for (final patient in patientList) {
        if (patient?.key?.isNotEmpty == true) {
          await _sqliteRepo.addItem(patient!);
        }
      }

      return patientList;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<SuccessModel> addPatient(Map<String, dynamic> data, String key) async {
    final patient = PatientModel.fromJson(data);
    print("patiemt is ${patient.toJson()}");
    await _sqliteRepo.addItem(patient);
    final response = await _clientSourceRepo.request(
      HttpMethod.PATCH,
      "/${ApiConstatns.patients}/$key.json",
      params: data,
    );

    return SuccessModel.fromJson(response);
  }

  @override
  Future<SuccessModel> deletePatient(
    Map<String, dynamic> data,
    String key,
  ) async {
    await _sqliteRepo.deleteItem(key);

    final response = await _clientSourceRepo.request(
      HttpMethod.DELETE,
      "/${ApiConstatns.patients}/$key.json",
      params: data,
    );

    return SuccessModel.fromJson(response ?? {"message": "تمت العملية بنجاح"});
  }

  @override
  Future<SuccessModel> updatePatient(
    Map<String, dynamic> data,
    String key,
  ) async {
    final patient = PatientModel.fromJson(data);
    await _sqliteRepo.updateItem(patient);

    final response = await _clientSourceRepo.request(
      HttpMethod.PATCH,
      "/${ApiConstatns.patients}/$key.json",
      params: data,
    );

    return SuccessModel.fromJson(response);
  }
}
