import '../../../index/index_main.dart';

/// Returns the primary pharmacy to attach to an order automatically.
/// Primary = account where pharmacy_id == uid (the owner account).
///
/// - 0 pharmacies → null
/// - 1+ pharmacies → first primary returned with no UI interaction
class PharmacyPickerService {
  PharmacyPickerService._();

  static Future<LocalUser?> pick() async {
    final completer = Completer<List<LocalUser?>>();

    // Only fetch the primary account (pharmacy_id == uid means this IS the pharmacy owner)
    AuthenticationService().getClientsData(
      query: SQLiteQueryParams(
        where: "userType = ? AND pharmacy_id = uid",
        whereArgs: ["pharmacy"],
        limit: 1,
      ),
      voidCallBack: (users) => completer.complete(users),
    );

    final all = await completer.future;
    return all.whereType<LocalUser>().firstOrNull;
  }
}
