import '../../../index/index_main.dart';

/// Returns the primary pharmacy to attach to an order automatically.
/// Primary = account where pharmacy_id == uid (the owner account).
///
/// Always fetches from Firebase (online) so the pharmacy_key in the order
/// is always current — never from a stale SQLite cache.
class PharmacyPickerService {
  PharmacyPickerService._();

  static Future<LocalUser?> pick() async {
    final completer = Completer<List<LocalUser>>();

    // Query Firebase online — primary accounts only (pharmacy_id == uid)
    await AuthenticationService().getClientsOnlineData(
      firebaseFilter: FirebaseFilter(orderBy: "userType", equalTo: "pharmacy"),
      voidCallBack: (users) => completer.complete(users),
    );

    final all = await completer.future;

    // Return the first primary account (uid == pharmacyId)
    return all.firstWhereOrNull(
      (u) => u.uid != null && u.uid == u.pharmacyId,
    );
  }
}
