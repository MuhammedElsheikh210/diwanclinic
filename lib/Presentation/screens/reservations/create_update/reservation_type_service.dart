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
    required String? newAppointmentDate, // ✅ التاريخ الجديد
    required String? selectedType,
    int? manualRevisitCount,
  }) {
    print("\n🧠 ===== ReservationTypeService.determine START =====");

    print("👉 selectedType: $selectedType");
    print("👉 newAppointmentDate: $newAppointmentDate");
    print("👉 maxRevisitCount: $maxRevisitCount");
    print("👉 revisitValidityDays: $revisitValidityDays");

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

    /// 🟡 CASE 1: مفيش حجز سابق
    if (lastReservation == null) {
      print("❌ lastReservation = NULL");

      if (selectedType == "إعادة") {
        final count = manualRevisitCount ?? 1;

        print("🟡 CASE 1A → Manual Revisit | count: $count");

        return ReservationTypeResult(
          type: "إعادة",
          revisitCount: count,
          parentKey: "MANUAL_PARENT",
        );
      }

      print("🟡 CASE 1B → New Reservation");

      return const ReservationTypeResult(
        type: "كشف جديد",
        revisitCount: 0,
        parentKey: "",
      );
    }

    /// 🟢 حساب الفرق بين التواريخ الصح
    final lastDate = parse(lastReservation.appointmentDateTime);
    final newDate = parse(newAppointmentDate);

    final diffDays = newDate.difference(lastDate).inDays;

    print("📅 lastDate: $lastDate");
    print("📅 newDate: $newDate");
    print("⏱ diffDays: $diffDays");

    /// 🔴 CASE 2: خارج المدة
    if (diffDays > revisitValidityDays) {
      print("🔴 CASE 2 → Expired");

      return const ReservationTypeResult(
        type: "كشف جديد",
        revisitCount: 0,
        parentKey: "",
      );
    }

    final lastType = lastReservation.reservationType;
    final lastCount = lastReservation.revisitCount ?? 0;

    print("📊 lastType: $lastType | lastCount: $lastCount");

    /// 🟣 CASE 3: آخر حجز = جديد
    if (lastType == "كشف جديد") {
      print("🟣 CASE 3 → New → Revisit = 1");

      return ReservationTypeResult(
        type: "إعادة",
        revisitCount: 1,
        parentKey: lastReservation.key ?? "",
      );
    }

    /// 🟠 CASE 4: آخر حجز = إعادة
    if (lastType == "إعادة") {
      /// 🔴 وصل للحد الأقصى
      if (lastCount >= maxRevisitCount) {
        print("🟠 CASE 4A → Max Reached → New");

        return const ReservationTypeResult(
          type: "كشف جديد",
          revisitCount: 0,
          parentKey: "",
        );
      }

      /// 🟢 يكمل إعادة
      final nextCount = lastCount + 1;

      print("🟠 CASE 4B → Continue Revisit | nextCount: $nextCount");

      return ReservationTypeResult(
        type: "إعادة",
        revisitCount: nextCount,
        parentKey: lastReservation.parentKey ?? lastReservation.key ?? "",
      );
    }

    /// ⚠️ fallback
    print("⚠️ FALLBACK CASE");

    return const ReservationTypeResult(
      type: "كشف جديد",
      revisitCount: 0,
      parentKey: "",
    );
  }
}