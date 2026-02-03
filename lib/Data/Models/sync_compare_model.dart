
import 'package:diwanclinic/Data/data_source/Authentication_Remote_DataSource.dart';

class SyncStatusModel {
  final String? key;
  final int? lastUpdateTimestamp;
  final int? lastAddDataTimestamp;
  final SyncStatus? syncStatus;

  const SyncStatusModel({
    this.key,
    this.lastUpdateTimestamp,
    this.lastAddDataTimestamp,
    this.syncStatus
  });

  /// Create instance from JSON map
  factory SyncStatusModel.fromJson(Map<String, dynamic> json) {
    return SyncStatusModel(
      key: json['key'] as String?,
      lastUpdateTimestamp: json['last_update_timestamp'] as int?,
      lastAddDataTimestamp: json['last_add_data_timestamp'] as int?,
    );
  }

  /// Convert back to JSON map
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'last_update_timestamp': lastUpdateTimestamp,
      'last_add_data_timestamp': lastAddDataTimestamp,
    };
  }

  /// CopyWith for immutability
  SyncStatusModel copyWith({
    String? key,
    int? lastUpdateTimestamp,
    int? lastAddDataTimestamp,
  }) {
    return SyncStatusModel(
      key: key ?? this.key,
      lastUpdateTimestamp: lastUpdateTimestamp ?? this.lastUpdateTimestamp,
      lastAddDataTimestamp:
      lastAddDataTimestamp ?? this.lastAddDataTimestamp,
    );
  }
}
