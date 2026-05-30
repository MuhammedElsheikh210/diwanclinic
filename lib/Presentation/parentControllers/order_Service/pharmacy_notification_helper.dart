import 'package:firebase_database/firebase_database.dart';
import '../../../index/index_main.dart';

/// Notifies every pharmacy staff member when a new order arrives.
///
/// Source of truth: Firebase `pharmacy_staff/{pharmacyId}/{uid}` node.
/// Each staff device writes its own FCM token there on every login via
/// [LoginViewModel._updateFcmToken], so this node is always current —
/// independent of whether the doctor's local SQLite is up to date.
class PharmacyNotificationHelper {
  PharmacyNotificationHelper._();

  static Future<void> notifyAllPharmacyStaff({
    required String pharmacyId,
    required OrderModel order,
  }) async {
    if (pharmacyId.isEmpty) return;

    // ── 1. Read all staff entries from Firebase ───────────────────
    final staffSnapshot = await FirebaseDatabase.instance
        .ref("pharmacy_staff/$pharmacyId")
        .get();

    if (!staffSnapshot.exists || staffSnapshot.value == null) return;

    final staffMap = Map<String, dynamic>.from(staffSnapshot.value as Map);
    final db = FirebaseDatabase.instance;
    final sessionUser = Get.find<UserSession>().user?.user;

    // ── 2. Write a notification node for each staff member ────────
    for (final entry in staffMap.entries) {
      final staffData = Map<String, dynamic>.from(entry.value as Map);
      final targetUid = (staffData['uid'] as String?)?.trim() ?? entry.key;

      if (targetUid.isEmpty) continue;

      final notifKey = const Uuid().v4();

      await db.ref("notifications/$targetUid/$notifKey").set({
        'key': notifKey,
        'from_key': sessionUser?.uid,
        'to_key': targetUid,
        'title': '💊 طلب روشتة جديد',
        'body': 'طلب جديد من ${order.patientName ?? "مريض"}',
        'notification_type': 'new_pharmacy_order',
        'create_at': DateTime.now().millisecondsSinceEpoch,
        'is_read': false,
        'extra_data': {
          'order_key': order.key,
          'patient_name': order.patientName,
        },
      });
    }
  }
}
