// ignore_for_file: depend_on_referenced_packages
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

import '../../../index/index_main.dart';

class MainPageViewModel extends GetxController {
  UserType? userType;

  bool get isDoctor => userType == UserType.doctor;

  bool get isPatient => userType == UserType.patient;

  bool get isAssistant => userType == UserType.assistant;

  bool get isSales => userType == UserType.sales;

  bool get isPharmacy => userType == UserType.pharmacy;

  bool get isAdmin => userType == UserType.admin;
  StreamSubscription<DatabaseEvent>? _clientsSyncSubscription;
  bool _isClientsSyncing = false;
  int _lastHandledTimestamp = 0;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _fetchUserFromFirebase();
    _listenToClientsSync(); // 🔥 هنا
  }

  void _listenToClientsSync() {
    _clientsSyncSubscription?.cancel();

    final ref = FirebaseDatabase.instance.ref("sync_meta/clients");

    _clientsSyncSubscription = ref.onValue.listen((event) async {
      final data = event.snapshot.value;
      if (data == null) return;

      final json = Map<String, dynamic>.from(data as Map);

      final int lastAdd = json['last_add_data_timestamp'] ?? 0;
      final int lastSync = json['last_update_timestamp'] ?? 0;

      if (lastAdd == lastSync) return;
      if (_isClientsSyncing) return;
      if (_lastHandledTimestamp == lastAdd) return;

      _isClientsSyncing = true;
      _lastHandledTimestamp = lastAdd;

      print("🔄 Clients Realtime Sync Triggered");

      await _runClientsFullSync();
      await _runReservationsFullSync();

      await ref.update({"last_update_timestamp": lastAdd});

      _isClientsSyncing = false;

      print("✅ Clients Sync Completed");
    });
  }

  Future<void> _runReservationsFullSync() async {
    try {
      print("⬇ Clearing local reservations...");

      final today = DateFormat('dd/MM/yyyy').format(DateTime.now());

      print("⬇ Downloading reservations from Firebase...");

      await ReservationService().getReservationsData(

        query: SQLiteQueryParams(),
        voidCallBack: (_) {},
      );

      print("✅ Reservations synced successfully");
    } catch (e) {
      print("❌ Reservations Sync Error: $e");
    }
  }

  Future<void> _runClientsFullSync() async {
    try {
      print("⬇ Downloading all clients...");

      await AuthenticationService().clearLocalClients();

      await AuthenticationService().getClientsData(
        isFiltered: false,
        query: SQLiteQueryParams(is_filtered: false),
        voidCallBack: (_) {},
      );

      print("✅ Local Clients Updated");
    } catch (e) {
      print("❌ Sync Error: $e");
    }
  }

  @override
  void onClose() {
    _clientsSyncSubscription?.cancel();
    super.onClose();
  }

  Future<void> _fetchUserFromFirebase() async {
    try {
      //   Loader.show();

      // 🔹 Get logged-in user's UID stored locally
      final uid = LocalUser().getUserData().uid ?? "";
      if (uid.isEmpty) {
        Loader.showError("No logged-in user found");
        Loader.dismiss();
        return;
      }

      // 🔥 LOCAL ONLY: load user from SQLite
      await AuthenticationService().getClientsLocalData(
        isFiltered: false, // local-only mode
        query: SQLiteQueryParams(
          is_filtered: false,
          where: "token = ?", // user UID saved as `token`
          whereArgs: [uid],
          limit: 1,
        ),
        voidCallBack: (List<LocalUser?> users) async {
          Loader.dismiss();

          if (users.isEmpty) {
            print("⚠️ No user found locally with UID: $uid");
            userType = null;
          } else {
            final user = users.first!;
            userType = user.userType;
            print("📘 Loaded user from LOCAL database is ${user.toJson()}");

            // Optional: ensure sync consistency
            user.saveLocal(saveCallback: () {});
          }

          update();
        },
      );
    } catch (e) {
      Loader.dismiss();
      print("❌ Error in local user fetch: $e");
    }
  }
}
