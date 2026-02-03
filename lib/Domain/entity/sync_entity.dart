import 'package:equatable/equatable.dart';

class SyncEntity extends Equatable {
  final String? key; // 🔑 New key
  final int? invoice;
  final int? merchant;
  final int? transactions;
  final int? curior;
  final int? wallet;

  const SyncEntity({
    this.key,
    this.invoice,
    this.merchant,
    this.transactions,
    this.curior,
    this.wallet,
  });

  @override
  List<Object?> get props => [key, invoice, merchant, transactions, curior, wallet];

  SyncEntity copyWith({
    String? key,
    int? invoice,
    int? merchant,
    int? transactions,
    int? curior,
    int? wallet,
  }) {
    return SyncEntity(
      key: key ?? this.key,
      invoice: invoice ?? this.invoice,
      merchant: merchant ?? this.merchant,
      transactions: transactions ?? this.transactions,
      curior: curior ?? this.curior,
      wallet: wallet ?? this.wallet,
    );
  }

  factory SyncEntity.fromJson(Map<String, dynamic> json) {
    return SyncEntity(
      key: json['key'],
      invoice: json['invoice'],
      merchant: json['merchant'],
      transactions: json['transactions'],
      curior: json['curior'],
      wallet: json['wallet'],
    );
  }

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
