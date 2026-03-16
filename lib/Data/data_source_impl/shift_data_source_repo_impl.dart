import '../../index/index_main.dart';

class ShiftDataSourceRepoImpl extends ShiftDataSourceRepo {
  final ClientSourceRepo _clientSourceRepo;

  ShiftDataSourceRepoImpl(this._clientSourceRepo);

  /// 🔹 API Paths
  String _shiftsPath(String? doctorKey) =>
      "/${ApiConstatns.shifts}/$doctorKey/shifts.json";

  String _shiftItemPath(String? doctorKey, String key) =>
      "/${ApiConstatns.shifts}/$doctorKey/shifts/$key.json";

  String _shiftsPatientPath(String? doctorKey) =>
      "/${ApiConstatns.shiftsFromPatient}/$doctorKey/shifts.json";

  /// 🕒 Get shifts for doctor
  @override
  Future<List<ShiftModel?>> getShifts(
      Map<String, dynamic> data,
      String? doctorKey,
      ) async {
    try {
      if (doctorKey == null || doctorKey.isEmpty) {
        return [];
      }

      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        _shiftsPath(doctorKey),
        params: data,
      );

      if (response == null || response.isEmpty) {
        return [];
      }

      return handleResponse<ShiftModel>(
        response,
            (json) => ShiftModel.fromJson(json),
      );
    } catch (e) {
      print("❌ getShifts error: $e");
      return [];
    }
  }

  /// 👨‍⚕️ Get shifts for patient
  @override
  Future<List<ShiftModel?>> getShiftsFromPatient(
      Map<String, dynamic> data,
      String? doctorKey,
      ) async {
    try {
      if (doctorKey == null || doctorKey.isEmpty) {
        return [];
      }

      final response = await _clientSourceRepo.request(
        HttpMethod.GET,
        _shiftsPatientPath(doctorKey),
        params: data,
      );

      if (response == null || response.isEmpty) {
        return [];
      }

      return handleResponse<ShiftModel>(
        response,
            (json) => ShiftModel.fromJson(json),
      );
    } catch (e) {
      print("❌ getShiftsFromPatient error: $e");
      return [];
    }
  }

  /// ➕ Add shift
  @override
  Future<SuccessModel> addShift(
      Map<String, dynamic> data,
      String key,
      String? doctorKey,
      ) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.PATCH,
        _shiftItemPath(doctorKey, key),
        params: data,
      );

      return SuccessModel.fromJson(response);
    } catch (e) {
      print("❌ addShift error: $e");
      return SuccessModel(message: "حدث خطأ أثناء إضافة الفترة");
    }
  }

  /// ❌ Delete shift
  @override
  Future<SuccessModel> deleteShift(
      Map<String, dynamic> data,
      String key,
      String? doctorKey,
      ) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.DELETE,
        _shiftItemPath(doctorKey, key),
        params: data,
      );

      return SuccessModel.fromJson(response ?? {"message": "تم الحذف بنجاح"});
    } catch (e) {
      print("❌ deleteShift error: $e");
      return SuccessModel(message: "فشل حذف الفترة");
    }
  }

  /// ✏️ Update shift
  @override
  Future<SuccessModel> updateShift(
      Map<String, dynamic> data,
      String key,
      String? doctorKey,
      ) async {
    try {
      final response = await _clientSourceRepo.request(
        HttpMethod.PATCH,
        _shiftItemPath(doctorKey, key),
        params: data,
      );

      return SuccessModel.fromJson(response);
    } catch (e) {
      print("❌ updateShift error: $e");
      return SuccessModel(message: "فشل تحديث بيانات الفترة");
    }
  }
}