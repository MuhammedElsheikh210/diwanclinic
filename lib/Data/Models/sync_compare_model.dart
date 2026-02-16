class SyncStatusModel {
  final int lastUpdateTimestamp;
  final int lastAddDataTimestamp;

  const SyncStatusModel({
    required this.lastUpdateTimestamp,
    required this.lastAddDataTimestamp,
  });

  factory SyncStatusModel.fromJson(Map<String, dynamic> json) {
    return SyncStatusModel(
      lastUpdateTimestamp: json['last_update_timestamp'] ?? 0,
      lastAddDataTimestamp: json['last_add_data_timestamp'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'last_update_timestamp': lastUpdateTimestamp,
      'last_add_data_timestamp': lastAddDataTimestamp,
    };
  }
}
