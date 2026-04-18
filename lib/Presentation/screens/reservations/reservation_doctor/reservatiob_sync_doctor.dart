import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import '../../../../index/index_main.dart';
import 'package:firebase_database/firebase_database.dart' as firebase_database;

class ReservationDocTorSyncService {
  StreamSubscription<DatabaseEvent>? _subscription;
  final ReservationDoctorViewModel? controller;

  ReservationDocTorSyncService({this.controller});

  void listen({
    required ClinicModel? selectedClinic,
    required String? appointmentDate,
    required Function(ReservationModel) onUpdatedLocal,
    required Function(ReservationModel) onAddLocal,
    required Function() onReloadLocal,
  }) {
    _subscription?.cancel();

    final user = Get.find<UserSession>().user;

    final doctorKey = user?.doctorKey ?? user?.uid ?? "";

    final String today = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final String basePath = 'doctors/$doctorKey/reservations/$today';

    final dbRef = FirebaseDatabase.instance.ref(basePath);

    firebase_database.Query query = dbRef;

    if (selectedClinic?.key != null) {
      query = query.orderByChild('clinic_key').equalTo(selectedClinic!.key);
    } else if (appointmentDate != null) {
      query = query
          .orderByChild('appointment_date_time')
          .equalTo(appointmentDate);
    }

    query.onChildAdded.listen((event) async {
      final data = event.snapshot.value;
      if (data == null) return;

      final json = Map<String, dynamic>.from(data as Map);
      final model = ReservationModel.fromJson(json);

      controller?.isSyncing = true;
      await onAddLocal(model);
      controller?.isSyncing = false;

      onReloadLocal();
    });

    query.onChildChanged.listen((event) async {
      final data = event.snapshot.value;
      if (data == null) return;

      final json = Map<String, dynamic>.from(data as Map);
      final model = ReservationModel.fromJson(json);

      controller?.isSyncing = true;
      await onUpdatedLocal(model);
      controller?.isSyncing = false;

      onReloadLocal();
    });
  }

  void dispose() {
    _subscription?.cancel();
  }
}
