import 'package:intl/intl.dart';
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
    required String? newAppointmentDate,
    required String? selectedType,
    int? manualRevisitCount,
  }) {
    print("\n🧠 ===== ReservationTypeService.determine START =====");

    print("👉 selectedType: $selectedType");
    print("👉 newAppointmentDate: $newAppointmentDate");

    /// 🔧 helper لتحويل التاريخ
    DateTime parse(String? date) {
      if (date == null || date.isEmpty) {
        return DateTime.now();
      }

      try {
        return DateFormat("dd-MM-yyyy").parse(date);
      } catch (_) {
        return DateTime.now();
      }
    }

    /// ============================================================
    /// 🟢 1. USER DECISION (أولوية مطلقة)
    /// ============================================================
    if (selectedType != null && selectedType.isNotEmpty) {
      print("🧠 USER DECISION → $selectedType");

      /// 🆕 كشف جديد
      if (selectedType == "كشف جديد") {
        return const ReservationTypeResult(
          type: "كشف جديد",
          revisitCount: 0,
          parentKey: "",
        );
      }

      /// 🔁 إعادة (manual)
      if (selectedType == "إعادة") {
        final count = manualRevisitCount ?? 1;

        return ReservationTypeResult(
          type: "إعادة",
          revisitCount: count,
          parentKey: lastReservation?.key ?? "MANUAL_PARENT",
        );
      }

      /// ⚡ مستعجل أو أي نوع تاني
      return ReservationTypeResult(
        type: selectedType,
        revisitCount: 0,
        parentKey: "",
      );
    }

    /// ============================================================
    /// 🟡 2. مفيش حجز سابق
    /// ============================================================
    if (lastReservation == null) {
      print("❌ No last reservation → New");

      return const ReservationTypeResult(
        type: "كشف جديد",
        revisitCount: 0,
        parentKey: "",
      );
    }

    /// ============================================================
    /// 🟢 3. حساب فرق الأيام
    /// ============================================================
    final lastDate = parse(lastReservation.appointmentDateTime);
    final newDate = parse(newAppointmentDate);

    final diffDays = newDate.difference(lastDate).inDays;

    print("📅 lastDate: $lastDate");
    print("📅 newDate: $newDate");
    print("⏱ diffDays: $diffDays");

    /// 🔴 خارج المدة → جديد
    if (diffDays > revisitValidityDays) {
      print("🔴 Expired → New");

      return const ReservationTypeResult(
        type: "كشف جديد",
        revisitCount: 0,
        parentKey: "",
      );
    }

    final lastType = lastReservation.reservationType;
    final lastCount = lastReservation.revisitCount ?? 0;

    print("📊 lastType: $lastType | lastCount: $lastCount");

    /// ============================================================
    /// 🟣 4. AUTO LOGIC
    /// ============================================================

    /// 🆕 لو آخر حجز جديد → أول إعادة
    if (lastType == "كشف جديد") {
      print("🟣 Auto → First Revisit");

      return ReservationTypeResult(
        type: "إعادة",
        revisitCount: 1,
        parentKey: lastReservation.key ?? "",
      );
    }

    /// 🔁 لو آخر حجز إعادة
    if (lastType == "إعادة") {
      /// 🔴 وصل للحد → جديد
      if (lastCount >= maxRevisitCount) {
        print("🟠 Max Reached → New");

        return const ReservationTypeResult(
          type: "كشف جديد",
          revisitCount: 0,
          parentKey: "",
        );
      }

      /// 🟢 يكمل إعادة
      final nextCount = lastCount + 1;

      print("🟠 Continue Revisit → $nextCount");

      return ReservationTypeResult(
        type: "إعادة",
        revisitCount: nextCount,
        parentKey: lastReservation.parentKey ?? lastReservation.key ?? "",
      );
    }

    /// ============================================================
    /// ⚠️ fallback
    /// ============================================================
    print("⚠️ FALLBACK → New");

    return const ReservationTypeResult(
      type: "كشف جديد",
      revisitCount: 0,
      parentKey: "",
    );
  }
}
