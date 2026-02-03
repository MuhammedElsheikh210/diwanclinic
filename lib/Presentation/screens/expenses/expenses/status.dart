
import 'package:diwanclinic/Global/Constatnts/TextConstants.dart';

enum BilesStatus { current, not_paid, comming, finished, cancel, removed }

extension BilesStatusExtension on BilesStatus {
  /// Returns the string value of the status.
  String get value {
    switch (this) {
      case BilesStatus.not_paid:
        return Strings.not_paid;
      case BilesStatus.comming:
        return Strings.comming;
      case BilesStatus.finished:
        return Strings.finished;
      case BilesStatus.current:
        return Strings.current;
      case BilesStatus.cancel:
        return Strings.cancel;
      case BilesStatus.removed:
        return Strings.removed; // Ensure Strings.removed is defined.
    }
  }
}

/// Calculates the invoice status based on [totalAmount] and [restAmount].
/// If both amounts are equal, the status is `finished`; otherwise, it is `current`.
BilesStatus calculateBilesStatus(String totalAmount, String restAmount) {
  final total = double.tryParse(totalAmount) ?? 0;
  final rest = double.tryParse(restAmount) ?? 0;
  return total == rest ? BilesStatus.finished : BilesStatus.current;
}
