// import '../../../index/index_main.dart';
//
// class ReservationSyncWorker {
//   final ReservationDataSourceRepo _local;
//   final ClientSourceRepo _client;
//   final ConnectivityService _connectivity;
//
//   bool _isRunning = false;
//
//   ReservationSyncWorker(this._local, this._client, this._connectivity);
//
//   // ============================================================
//   // 🔥 PUBLIC ENTRY — Called when:
//   // 1️⃣ Internet comes back
//   // 2️⃣ After creating reservation (if online)
//   // ============================================================
//
//   Future<void> triggerIfOnline() async {
//     final isOnline = await _connectivity.isOnline();
//
//     if (isOnline) {
//       await processQueue();
//     }
//   }
//
//   // ============================================================
//   // 🔄 PROCESS FULL QUEUE
//   // ============================================================
//
//   Future<void> processQueue() async {
//     if (_isRunning) return;
//
//     _isRunning = true;
//
//     try {
//       final pending = await _local.getPendingReservations();
//
//       if (pending.isEmpty) return;
//
//       for (final model in pending) {
//         await _syncSingle(model);
//       }
//     } catch (_) {
//       // Fail silently (can add logging here)
//     } finally {
//       _isRunning = false;
//     }
//   }
//
//   // ============================================================
//   // 🔄 SYNC SINGLE ITEM
//   // ============================================================
//
//   Future<void> _syncSingle(ReservationModel model) async {
//     if (model.key == null) return;
//
//     final safeDate = model.appointmentDateTime?.replaceAll("/", "-");
//
//     final path =
//         "doctors/${model.doctorKey}/reservations/$safeDate/${model.key}.json";
//
//     try {
//       switch (model.syncStatus) {
//         case SyncStatus.pendingCreate:
//         case SyncStatus.pendingUpdate:
//           await _client.request(
//             HttpMethod.PATCH,
//             "/$path",
//             params: model.toJson(),
//           );
//
//           break;
//
//         case SyncStatus.pendingDelete:
//           await _client.request(HttpMethod.DELETE, "/$path");
//
//           break;
//
//         default:
//           return;
//       }
//
//       // ✅ Mark as synced locally
//       await _local.markAsSynced(model.key!);
//     } catch (_) {
//       // 🔁 Optional: add retry counter later
//     }
//   }
// }
