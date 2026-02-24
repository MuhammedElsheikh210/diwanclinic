// import 'dart:async';
// import 'package:firebase_database/firebase_database.dart';
// import '../../../../index/index_main.dart';
//
// class NotificationSyncService {
//   StreamSubscription<DatabaseEvent>? _addedSub;
//   StreamSubscription<DatabaseEvent>? _changedSub;
//   StreamSubscription<DatabaseEvent>? _removedSub;
//
//   final NotificationController controller;
//
//   NotificationSyncService({required this.controller});
//
//   void listen({required String userKey}) {
//     dispose();
//
//     /// 🔥 notifications path (filtered by to_key)
//     final ref = FirebaseDatabase.instance
//         .ref('notifications')
//         .orderByChild('to_key')
//         .equalTo(userKey);
//
//     // ───────────── ADD ─────────────
//     _addedSub = ref.onChildAdded.listen((event) {
//       if (event.snapshot.value == null) return;
//
//       final json =
//       Map<String, dynamic>.from(event.snapshot.value as Map);
//
//       final model = NotificationModel.fromJson(json)
//         ..key = event.snapshot.key;
//
//       controller.onRealtimeAdd(model);
//     });
//
//     // ───────────── UPDATE ─────────────
//     _changedSub = ref.onChildChanged.listen((event) {
//       if (event.snapshot.value == null) return;
//
//       final json =
//       Map<String, dynamic>.from(event.snapshot.value as Map);
//
//       final model = NotificationModel.fromJson(json)
//         ..key = event.snapshot.key;
//
//       controller.onRealtimeUpdate(model);
//     });
//
//     // ───────────── REMOVE (🔥 المهم) ─────────────
//     _removedSub = ref.onChildRemoved.listen((event) {
//       final key = event.snapshot.key;
//       if (key == null) return;
//
//       controller.onRealtimeDelete(key);
//     });
//   }
//
//   void dispose() {
//     _addedSub?.cancel();
//     _changedSub?.cancel();
//     _removedSub?.cancel();
//
//     _addedSub = null;
//     _changedSub = null;
//     _removedSub = null;
//   }
// }
