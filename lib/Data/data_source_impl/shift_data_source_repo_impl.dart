import 'package:diwanclinic/Data/data_source/shift_data_source.dart';
import '../../index/index_main.dart';

class ShiftDataSourceRepoImpl extends ShiftDataSourceRepo {
  final ClientSourceRepo _clientSourceRepo;

  ShiftDataSourceRepoImpl(this._clientSourceRepo);

  @override
  Future<List<ShiftModel?>> getShifts(
    Map<String, dynamic> data,
    SQLiteQueryParams query,
    bool? isFiltered,
  ) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        "/${ApiConstatns.shifts}.json",
        params: data,
      );

      if (response == null || response.isEmpty) {
        return [];
      }

      final shiftList = handleResponse<ShiftModel>(
        response,
        (json) => ShiftModel.fromJson(json),
      );

      return shiftList;
    } catch (e) {
      return [];
    }
  }

  /// 🩺 Fetch shifts related to a specific doctor (for patient view)
  @override
  Future<List<ShiftModel?>> getShiftssFromPatient(
    Map<String, dynamic> data,
    String? doctorKey,
  ) async {
    try {
      if (doctorKey == null || doctorKey.isEmpty) {
        return [];
      }

      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        "/${ApiConstatns.shiftsFromPatient}$doctorKey/shifts.json",
        params: data,
      );

      if (response == null || response.isEmpty) {
        return [];
      }

      final shifts = handleResponse<ShiftModel>(
        response,
        (json) => ShiftModel.fromJson(json),
      );

      return shifts;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<SuccessModel> addShift(Map<String, dynamic> data, String key) async {
    try {
      final shift = ShiftModel.fromJson(data);

      final response = await _clientSourceRepo.request(
        HttpMethod.PATCH,
        "/${ApiConstatns.shifts}/$key.json",
        params: data,
      );

      return SuccessModel.fromJson(response);
    } catch (e) {
      return SuccessModel(message: "حدث خطأ أثناء إضافة الفترة");
    }
  }

  @override
  Future<SuccessModel> deleteShift(
    Map<String, dynamic> data,
    String key,
  ) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.DELETE,
        "/${ApiConstatns.shifts}/$key.json",
        params: data,
      );

      return SuccessModel.fromJson(response ?? {"message": "تم الحذف بنجاح"});
    } catch (e) {
      return SuccessModel(message: "فشل حذف الفترة");
    }
  }

  @override
  Future<SuccessModel> updateShift(
    Map<String, dynamic> data,
    String key,
  ) async {
    try {
      final shift = ShiftModel.fromJson(data);

      final response = await _clientSourceRepo.request(
        HttpMethod.PATCH,
        "/${ApiConstatns.shifts}/$key.json",
        params: data,
      );

      return SuccessModel.fromJson(response);
    } catch (e) {
      return SuccessModel(message: "فشل تحديث بيانات الفترة");
    }
  }
}
