import '../../index/index_main.dart';

class SyncModel extends SyncEntity {
  const SyncModel({
    String? key,
    int? invoice,
    int? merchant,
    int? transactions,
    int? curior,
    int? wallet,
  }) : super(
         key: key,
         invoice: invoice,
         merchant: merchant,
         transactions: transactions,
         curior: curior,
         wallet: wallet,
       );

  /// ✅ **Create a `SyncModel` from JSON**
  factory SyncModel.fromJson(Map<String, dynamic> json) {
    return SyncModel(
      key: json['key'],
      invoice: json['invoice'],
      merchant: json['merchant'],
      transactions: json['transactions'],
      curior: json['curior'],
      wallet: json['wallet'],
    );
  }

  /// ✅ **Convert `SyncModel` to JSON**
  @override
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'invoice': invoice,
      'merchant': merchant,
      'transactions': transactions,
      'curior': curior,
      'wallet': wallet,
    };
  }
}
