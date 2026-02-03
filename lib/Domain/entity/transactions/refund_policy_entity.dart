import 'package:equatable/equatable.dart';

import '../../../index/index_main.dart';

class RefundInfoEntity extends Equatable {
  final int? is_refund;
  final int? refund_duration;

  const RefundInfoEntity({
    this.is_refund,
    this.refund_duration,
  });

  @override
  List<Object?> get props => [is_refund, refund_duration];

  factory RefundInfoEntity.fromJson(Map<String, dynamic> json) {
    return RefundInfoEntity(
      is_refund: json['is_refund'],
      refund_duration: json['refund_duration'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    void addIfPresent(String key, dynamic value) {
      if (value != null) data[key] = value;
    }

    addIfPresent('is_refund', is_refund);
    addIfPresent('refund_duration', refund_duration);

    return data;
  }

  RefundInfoEntity copyWith({
    int? is_refund,
    int? refund_duration,
  }) {
    return RefundInfoEntity(
      is_refund: is_refund ?? this.is_refund,
      refund_duration: refund_duration ?? this.refund_duration,
    );
  }
}
