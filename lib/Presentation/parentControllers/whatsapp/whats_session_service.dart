import 'package:firebase_database/firebase_database.dart';

class WhatsAppSessionService {
  // =========================================================
  // 🔥 SESSION STATES
  // =========================================================

  static const String awaitingPrescription = "awaiting_prescription";

  static const String inOrder = "in_order";

  static const String calculated = "calculated";

  static const String confirmed = "confirmed";

  static const String completed = "completed";

  static const String orderConfirmed = "order_confirmed";

  static const String cancelled = "cancelled";

  // =========================================================
  // 🔥 CLEAN PHONE
  // =========================================================

  static String _cleanPhone(String phone) {
    phone = phone.replaceAll("+", "").trim();

    if (phone.startsWith("0")) {
      return "20${phone.substring(1)}";
    }

    if (phone.startsWith("20")) {
      return phone;
    }

    return phone;
  }

  // =========================================================
  // 🔥 SESSION REF
  // =========================================================

  static DatabaseReference _sessionRef(String phone) {
    final clean = _cleanPhone(phone);

    return FirebaseDatabase.instance.ref("users_sessions/$clean");
  }

  // =========================================================
  // 🔥 START SESSION
  // =========================================================

  static Future<void> startPrescriptionSession({
    required String phone,

    required String reservationId,

    String? doctorKey,

    String? clinicKey,

    String? doctorName,
  }) async {
    try {
      if (phone.isEmpty) return;

      await _sessionRef(phone).set({
        "step": awaitingPrescription,

        "reservationId": reservationId,

        "doctorKey": doctorKey,

        "clinicKey": clinicKey,

        "doctorName": doctorName,

        "createdAt": DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print("❌ startPrescriptionSession ERROR: $e");
    }
  }

  // =========================================================
  // 🔥 ATTACH ORDER
  // =========================================================

  static Future<void> attachOrderToSession({
    required String phone,

    required String orderId,
  }) async {
    try {
      await _sessionRef(phone).update({
        "activeOrderId": orderId,

        "step": inOrder,

        "updatedAt": DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print("❌ attachOrderToSession ERROR: $e");
    }
  }

  // =========================================================
  // 🔥 UPDATE SESSION STATUS
  // =========================================================

  static Future<void> updateSessionStatus({
    required String phone,

    required String status,

    String? orderId,
  }) async {
    try {
      final data = {
        "step": status,

        "updatedAt": DateTime.now().millisecondsSinceEpoch,
      };

      // ✅ مهم جداً

      if (orderId != null && orderId.isNotEmpty) {
        data["activeOrderId"] = orderId;
      }

      await _sessionRef(phone).update(data);
    } catch (e) {
      print("❌ updateSessionStatus ERROR: $e");
    }
  }

  // =========================================================
  // 🔥 MARK CALCULATED
  // =========================================================

  static Future<void> markCalculated({
    required String phone,

    required String orderId,
  }) async {
    await updateSessionStatus(
      phone: phone,

      status: calculated,

      orderId: orderId,
    );
  }

  // =========================================================
  // 🔥 MARK CONFIRMED
  // =========================================================

  static Future<void> markConfirmed(String phone) async {
    await updateSessionStatus(phone: phone, status: confirmed);
  }

  // =========================================================
  // 🔥 MARK COMPLETED
  // =========================================================

  static Future<void> markCompleted(String phone) async {
    await updateSessionStatus(phone: phone, status: completed);
  }

  // =========================================================
  // 🔥 MARK CANCELLED
  // =========================================================

  static Future<void> markCancelled(String phone) async {
    await updateSessionStatus(phone: phone, status: cancelled);
  }

  // =========================================================
  // 🔥 GET SESSION
  // =========================================================

  static Future<Map<String, dynamic>?> getSession(String phone) async {
    try {
      final snap = await _sessionRef(phone).get();

      if (!snap.exists) {
        return null;
      }

      return Map<String, dynamic>.from(snap.value as Map);
    } catch (e) {
      print("❌ getSession ERROR: $e");

      return null;
    }
  }

  // =========================================================
  // 🔥 CLEAR SESSION
  // =========================================================

  static Future<void> clearSession(String phone) async {
    try {
      await _sessionRef(phone).remove();
    } catch (e) {
      print("❌ clearSession ERROR: $e");
    }
  }
}
