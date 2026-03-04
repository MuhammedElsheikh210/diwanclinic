// import '../../../index/index_main.dart';
//
// class ReservationSyncController {
//   final ReservationSyncWorker _worker;
//   final ConnectivityService _connectivity;
//   final ReservationRemoteDataSource _remote;
//   final ReservationDataSourceRepo _local;
//
//   ReservationSyncController(
//     this._worker,
//     this._connectivity,
//     this._remote,
//     this._local,
//   );
//
//   // ============================================================
//   // 🔥 INIT
//   // ============================================================
//
//   void init() {
//     _connectivity.startListening();
//
//     _connectivity.onConnectionChange.listen((isOnline) {
//       if (isOnline) {
//         _worker.processQueue();
//       }
//     });
//
//     // 🔥 Check immediately on app start
//     _worker.triggerIfOnline();
//   }
//
//   // ============================================================
//   // ⚡ FAST PUSH FOR CREATE
//   // ============================================================
//
//   Future<void> pushSingleReservation(ReservationModel reservation) async {
//     try {
//       print("reservation.syncStatus is ${reservation.syncStatus}");
//       switch (reservation.syncStatus) {
//         case SyncStatus.pendingCreate:
//           await _remote.createReservation(reservation);
//           break;
//
//         case SyncStatus.pendingUpdate:
//           await _remote.updateReservation(reservation);
//           break;
//
//         case SyncStatus.pendingDelete:
//           await _remote.deleteReservation(reservation);
//           break;
//
//         default:
//           return;
//       }
//
//       await _local.markAsSynced(
//         reservation.key!,
//         serverUpdatedAt: DateTime.now().millisecondsSinceEpoch,
//       );
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   // ============================================================
//   // 🔥 DISPOSE
//   // ============================================================
//
//   void dispose() {
//     _connectivity.dispose();
//   }
// }
