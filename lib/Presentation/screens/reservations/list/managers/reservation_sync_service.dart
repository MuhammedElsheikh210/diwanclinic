import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import '../../../../../index/index_main.dart';

class ReservationSyncService {
  StreamSubscription<DatabaseEvent>? _addedSub;
  StreamSubscription<DatabaseEvent>? _changedSub;

  final ReservationViewModel? controller;

  ReservationSyncService({this.controller});

  void listen({
    required ClinicModel? selectedClinic,
     GenericListModel? selectedShift, // 🔥 مهم
    required String? appointmentDate,
    required Function(ReservationModel) onUpdatedLocal,
    required Function(ReservationModel) onAddLocal,
    required Function() onReloadLocal,
  }) {
    // 🛑 Cancel old listeners
    _addedSub?.cancel();
    _changedSub?.cancel();

    final user = LocalUser().getUserData();
    final doctorKey = user.doctorKey ?? user.uid ?? "";

    if (doctorKey.isEmpty) return;
    if (selectedShift?.key == null) return;

    final String today = DateFormat('dd-MM-yyyy').format(DateTime.now());

    // 🔥🔥🔥 NEW STRUCTURE
    final String basePath =
        'doctors/$doctorKey/reservations/$today/${selectedShift!.key}';

    final DatabaseReference dbRef = FirebaseDatabase.instance.ref(basePath);

    // ===============================
    // 🟢 CHILD ADDED
    // ===============================
    _addedSub = dbRef.onChildAdded.listen((event) async {
      final data = event.snapshot.value;
      if (data == null) return;

      try {
        final json = Map<String, dynamic>.from(data as Map);
        final model = ReservationModel.fromJson(json);

        controller?.isSyncing = true;
        await onAddLocal(model);
        controller?.isSyncing = false;

        onReloadLocal();
      } catch (e) {
        print("❌ onChildAdded Error: $e");
      }
    });

    // ===============================
    // 🟡 CHILD CHANGED
    // ===============================
    _changedSub = dbRef.onChildChanged.listen((event) async {
      final data = event.snapshot.value;
      if (data == null) return;

      try {
        final json = Map<String, dynamic>.from(data as Map);
        final model = ReservationModel.fromJson(json);

        controller?.isSyncing = true;
        await onUpdatedLocal(model);
        controller?.isSyncing = false;

        onReloadLocal();
      } catch (e) {
        print("❌ onChildChanged Error: $e");
      }
    });
  }

  void dispose() {
    _addedSub?.cancel();
    _changedSub?.cancel();
  }
}
