import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../../../../../index/index_main.dart';

class ReservationPatientSyncService {
  StreamSubscription<DatabaseEvent>? _addedSub;
  StreamSubscription<DatabaseEvent>? _changedSub;

  void listen({
    required String patientKey,
    required Function(ReservationModel) onAddLocal,
    required Function(ReservationModel) onUpdatedLocal,
  }) {
    dispose();

    final ref = FirebaseDatabase.instance.ref(
      "patients/$patientKey/reservations",
    );

    _addedSub = ref.onChildAdded.listen((event) async {
      if (event.snapshot.value == null) return;

      final json = Map<String, dynamic>.from(event.snapshot.value as Map);

      final model = ReservationModel.fromJson(json);
      await onAddLocal(model);
    });

    _changedSub = ref.onChildChanged.listen((event) async {
      if (event.snapshot.value == null) return;

      final json = Map<String, dynamic>.from(event.snapshot.value as Map);

      final model = ReservationModel.fromJson(json);
      await onUpdatedLocal(model);
    });
  }

  void dispose() {
    _addedSub?.cancel();
    _changedSub?.cancel();
  }
}
