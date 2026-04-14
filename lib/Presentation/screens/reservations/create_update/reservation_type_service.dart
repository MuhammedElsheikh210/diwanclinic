import '../../../../index/index_main.dart';

class ReservationTypeResult {
  final String type; // "كشف جديد" | "إعادة"
  final int revisitCount;
  final String parentKey;

  const ReservationTypeResult({
    required this.type,
    required this.revisitCount,
    required this.parentKey,
  });
}

class ReservationTypeService {
  static ReservationTypeResult determine({
    required ReservationModel? lastReservation,
    required int maxRevisitCount,
    required int revisitValidityDays,
    required int now,
    required String? selectedType,
    int? manualRevisitCount,
  }) {
    /// 🟡 CASE 1: مفيش تاريخ
    if (lastReservation == null) {
      if (selectedType == "إعادة") {
        final count = manualRevisitCount ?? 1;

        return ReservationTypeResult(
          type: "إعادة",
          revisitCount: count,
          parentKey: "MANUAL_PARENT",
        );
      }

      return ReservationTypeResult(
        type: "كشف جديد",
        revisitCount: 0,
        parentKey: "",
      );
    }

    /// 🟢 حساب الفرق بالايام
    final lastTime = lastReservation.createdAt ?? 0;
    final diffDays =
        (now - lastTime) ~/ (1000 * 60 * 60 * 24);

    /// 🔴 CASE 2: خارج المدة
    if (diffDays > revisitValidityDays) {
      return ReservationTypeResult(
        type: "كشف جديد",
        revisitCount: 0,
        parentKey: "",
      );
    }

    final lastType = lastReservation.reservationType;
    final lastCount = lastReservation.revisitCount ?? 0;

    /// 🟣 CASE 3: last = جديد
    if (lastType == "كشف جديد") {
      return ReservationTypeResult(
        type: "إعادة",
        revisitCount: 1,
        parentKey: lastReservation.key ?? "",
      );
    }

    /// 🟠 CASE 4: last = إعادة
    if (lastType == "إعادة") {
      if (lastCount >= maxRevisitCount) {
        return ReservationTypeResult(
          type: "كشف جديد",
          revisitCount: 0,
          parentKey: "",
        );
      }

      return ReservationTypeResult(
        type: "إعادة",
        revisitCount: lastCount + 1,
        parentKey:
        lastReservation.parentKey ??
            lastReservation.key ??
            "",
      );
    }

    /// fallback
    return ReservationTypeResult(
      type: "كشف جديد",
      revisitCount: 0,
      parentKey: "",
    );
  }
}