// clinic_adapter.dart
import '../../../../index/index_main.dart';

class ClinicModelAdapterUtil {
  static GenericListModel convertClinicToGeneric(ClinicModel? clinic) {
    return GenericListModel(
      key: clinic?.key ?? "",
      name: clinic?.title ?? "Unnamed Clinic",
    );
  }

  static List<GenericListModel> convertClinicListToGeneric(
    List<ClinicModel?> clinicList,
  ) {
    return clinicList.map((c) => convertClinicToGeneric(c)).toList();
  }
}

class ShiftModelAdapterUtil {
  static GenericListModel convertShiftToGeneric(ShiftModel? shift) {
    return GenericListModel(
      key: shift?.key ?? "",
      name: shift?.name ?? "Unnamed Shift",
    );
  }

  static List<GenericListModel> convertShiftListToGeneric(
    List<ShiftModel?> shiftList,
  ) {
    return shiftList.map((s) => convertShiftToGeneric(s)).toList();
  }
}

class ClinicAdapterUtil {
  /// 🔹 Convert a list of ClinicModel objects into GenericListModel for dropdown
  static List<GenericListModel> convertClinicListToGeneric(
    List<ClinicModel?>? clinics,
  ) {
    if (clinics == null || clinics.isEmpty) return [];

    return clinics.map((clinic) {
      return GenericListModel(
        key: clinic?.key ?? "",
        name: clinic?.title ?? "",
      );
    }).toList();
  }

  /// 🔹 Convert a single ClinicModel to GenericListModel
  static GenericListModel convertSingleClinicToGeneric(ClinicModel clinic) {
    return GenericListModel(key: clinic.key ?? "", name: clinic.title ?? "");
  }

  /// 🔹 Find ClinicModel by GenericListModel selection
  static ClinicModel? findClinicByGeneric(
    List<ClinicModel?>? clinics,
    GenericListModel? selected,
  ) {
    if (clinics == null || selected == null) return null;
    try {
      return clinics.firstWhere(
        (clinic) => clinic?.key == selected.key,
        orElse: () => ClinicModel(),
      );
    } catch (_) {
      return null;
    }
  }
}

/// ✅ Converts between [ClinicModel], [ShiftModel], and [GenericListModel]
class ModelAdapterUtil {
  // 🔹 CLINIC ADAPTERS

  /// Convert single ClinicModel to GenericListModel
  static GenericListModel clinicToGeneric(ClinicModel? clinic) {
    return GenericListModel(
      key: clinic?.key ?? "",
      name: clinic?.title?.isNotEmpty == true
          ? clinic!.title
          : "عيادة بدون اسم",
    );
  }

  /// Convert list of ClinicModel to GenericListModel list
  static List<GenericListModel> clinicListToGeneric(
    List<ClinicModel?>? clinics,
  ) {
    if (clinics == null || clinics.isEmpty) return [];
    return clinics.map(clinicToGeneric).toList();
  }

  /// Find ClinicModel from GenericListModel selection
  static ClinicModel? findClinicByGeneric(
    List<ClinicModel?>? clinics,
    GenericListModel? selected,
  ) {
    if (clinics == null || selected == null) return null;
    return clinics.firstWhereOrNull((c) => c?.key == selected.key);
  }

  // 🔹 SHIFT ADAPTERS

  /// Convert single ShiftModel to GenericListModel
  static GenericListModel shiftToGeneric(ShiftModel? shift) {
    return GenericListModel(
      key: shift?.key ?? "",
      name: shift?.name?.isNotEmpty == true
          ? "${shift!.name} (${shift.startTime ?? ""} - ${shift.endTime ?? ""})"
          : "فترة بدون اسم",
    );
  }

  /// Convert list of ShiftModel to GenericListModel list
  static List<GenericListModel> shiftListToGeneric(List<ShiftModel?>? shifts) {
    if (shifts == null || shifts.isEmpty) return [];
    return shifts.map(shiftToGeneric).toList();
  }

  /// Find ShiftModel from GenericListModel selection
  static ShiftModel? findShiftByGeneric(
    List<ShiftModel?>? shifts,
    GenericListModel? selected,
  ) {
    if (shifts == null || selected == null) return null;
    return shifts.firstWhereOrNull((s) => s?.key == selected.key);
  }
}
