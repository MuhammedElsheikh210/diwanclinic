import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

import '../../index/index_main.dart';

class ClientSyncService {
  StreamSubscription<DatabaseEvent>? _subscription;

  bool _isSyncing = false;
  int _lastHandledTimestamp = 0;

  final DatabaseReference _ref = FirebaseDatabase.instance.ref(
    "sync_meta/clients",
  );

  void listen({required Future<void> Function() onFullSync}) {
    _subscription?.cancel();

    _subscription = _ref.onValue.listen((event) async {
      final data = event.snapshot.value;

      // 🟢 First time
      if (data == null) {
        if (_isSyncing) return;

        _isSyncing = true;

        await onFullSync();
        await _createInitialSyncRecord();

        _isSyncing = false;
        return;
      }

      final json = Map<String, dynamic>.from(data as Map);
      final status = SyncStatusModel.fromJson(json);

      final int lastAdd = status.lastAddDataTimestamp;
      final int lastSync = status.lastUpdateTimestamp;

      
      

      // Already synced
      if (lastAdd == lastSync) return;

      // Prevent duplicate execution
      if (_isSyncing) return;
      if (_lastHandledTimestamp == lastAdd) return;

      _isSyncing = true;
      _lastHandledTimestamp = lastAdd;

      debugPrint("🔄 Running FULL CLIENT SYNC (Shared)...");

      await onFullSync();

      // 🔥 Update last_update_timestamp after finishing
      await _ref.update({"last_update_timestamp": lastAdd});

      _isSyncing = false;

      
    });
  }

  Future<void> _createInitialSyncRecord() async {
    final now = DateTime.now().millisecondsSinceEpoch;

    await _ref.set({
      "last_add_data_timestamp": now,
      "last_update_timestamp": now,
    });

    _lastHandledTimestamp = now;
  }

  void dispose() {
    _subscription?.cancel();
  }
}
