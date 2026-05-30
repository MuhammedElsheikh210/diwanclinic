import '../../../../../index/index_main.dart';

class PharmacyViewModel extends GetxController {
  List<LocalUser?>? listPharmacies;

  @override
  Future<void> onInit() async {
    getData();
    super.onInit();
  }

  void getData() {
    AuthenticationService().getClientsOnlineData(
      firebaseFilter: FirebaseFilter(orderBy: "userType", equalTo: "pharmacy"),
      voidCallBack: (data) {
        listPharmacies = data;
        update();
      },
    );
  }

  /// Groups pharmacy accounts by pharmacyId.
  /// Returns a map: pharmacyId → list of accounts.
  /// The primary account (uid == pharmacyId) comes first in each list.
  Map<String, List<LocalUser>> get groupedPharmacies {
    final Map<String, List<LocalUser>> result = {};

    for (final user in listPharmacies ?? []) {
      if (user == null) continue;
      final pid = user.pharmacyId ?? user.uid ?? 'unknown';
      result.putIfAbsent(pid, () => []).add(user);
    }

    // Primary account first:
    // uid == pharmacyId → explicitly marked primary
    // pharmacyId == null → old account created before feature (treated as primary)
    for (final list in result.values) {
      list.sort((a, b) {
        final aIsPrimary = a.pharmacyId == null || a.uid == a.pharmacyId;
        final bIsPrimary = b.pharmacyId == null || b.uid == b.pharmacyId;
        if (aIsPrimary && !bIsPrimary) return -1;
        if (!aIsPrimary && bIsPrimary) return 1;
        return 0;
      });
    }

    return result;
  }

  void deletePharmacy(LocalUser? pharmacy) {
    AuthenticationService().deleteClientsData(
      uid: pharmacy?.uid ?? "",
      voidCallBack: (_) {
        getData();
      },
    );
  }
}
