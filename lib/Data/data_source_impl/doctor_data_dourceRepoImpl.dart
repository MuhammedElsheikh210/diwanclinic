import 'package:diwanclinic/Data/data_source/doctor_data_source.dart';
import '../../index/index_main.dart';

class DoctorDataSourceRepoImpl extends DoctorDataSourceRepo {
  final ClientSourceRepo _clientSourceRepo;
  // final BaseSQLiteDataSourceRepo<DoctorModel> _sqliteRepo;

  DoctorDataSourceRepoImpl(this._clientSourceRepo)
  /*: _sqliteRepo = BaseSQLiteDataSourceRepo<DoctorModel>(
          tableName: "doctors",
          fromJson: (json) => DoctorModel.fromJson(json),
          toJson: (model) => model.toJson(),
          getId: (model) => model.key,
        )*/;

  @override
  Future<List<DoctorModel?>> getDoctors(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      ) async {
    try {
      // 🔸 Local fetch (disabled)
      // final sqliteData = await _sqliteRepo.getAll(query: query);
      // if (sqliteData.isNotEmpty || (sqliteData.isEmpty && isFiltered == true)) {
      //   return sqliteData;
      // }
    } catch (_) {}

    try {
      // 🔹 Online fetch
      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        "/${ApiConstatns.doctors}.json",
        params: data,
      );

      List<DoctorModel?> doctorList = handleResponse<DoctorModel>(
        response,
            (json) => DoctorModel.fromJson(json),
      );

      // 🔸 Save to local (disabled)
      // for (final doctor in doctorList) {
      //   if (doctor?.key?.isNotEmpty == true) {
      //     await _sqliteRepo.addItem(doctor!);
      //   }
      // }

      return doctorList;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<SuccessModel> addDoctor(Map<String, dynamic> data, String key) async {
    final doctor = DoctorModel.fromJson(data);

    // 🔸 Local add (disabled)
    // await _sqliteRepo.addItem(doctor);

    // 🔹 Online add
    final response = await _clientSourceRepo.request(
      HttpMethod.PATCH,
      "/${ApiConstatns.doctors}/$key.json",
      params: data,
    );

    return SuccessModel.fromJson(response);
  }

  @override
  Future<SuccessModel> deleteDoctor(Map<String, dynamic> data, String key) async {
    // 🔸 Local delete (disabled)
    // await _sqliteRepo.deleteItem(key);

    // 🔹 Online delete
    final response = await _clientSourceRepo.request(
      HttpMethod.DELETE,
      "/${ApiConstatns.doctors}/$key.json",
      params: data,
    );

    return SuccessModel.fromJson(response ?? {"message": "تمت العملية بنجاح"});
  }

  @override
  Future<SuccessModel> updateDoctor(Map<String, dynamic> data, String key) async {
    final doctor = DoctorModel.fromJson(data);

    // 🔸 Local update (disabled)
    // await _sqliteRepo.updateItem(doctor);

    // 🔹 Online update
    final response = await _clientSourceRepo.request(
      HttpMethod.PATCH,
      "/${ApiConstatns.doctors}/$key.json",
      params: data,
    );

    return SuccessModel.fromJson(response);
  }
}
