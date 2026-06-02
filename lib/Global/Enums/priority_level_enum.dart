import 'dart:ui';
import '../../index/index_main.dart';

/// Priority levels for the Smart Clinic Flow System.
/// Hard priority (level >= 3) bypasses the active window and goes to the front.
/// Soft priority (level 1-2) is preferred within the window but respects check-in order.
enum ReservationPriority {
  normal,   // 0 - كشف عادي
  vip,      // 1 - VIP
  elderly,  // 2 - كبار السن
  newborn,  // 3 - حديث ولادة (يدخل بعد حالتين في الطابور)
  urgent,   // 4 - طوارئ / حالة حرجة (hard priority)
}

extension ReservationPriorityExt on ReservationPriority {
  int get level {
    switch (this) {
      case ReservationPriority.normal:
        return 0;
      case ReservationPriority.vip:
        return 1;
      case ReservationPriority.elderly:
        return 2;
      case ReservationPriority.newborn:
        return 3;
      case ReservationPriority.urgent:
        return 4;
    }
  }

  String get label {
    switch (this) {
      case ReservationPriority.normal:
        return "عادي";
      case ReservationPriority.vip:
        return "VIP";
      case ReservationPriority.elderly:
        return "كبير السن";
      case ReservationPriority.newborn:
        return "حديث ولادة";
      case ReservationPriority.urgent:
        return "طوارئ";
    }
  }

  String get emoji {
    switch (this) {
      case ReservationPriority.normal:
        return "";
      case ReservationPriority.vip:
        return "⭐";
      case ReservationPriority.elderly:
        return "👴";
      case ReservationPriority.newborn:
        return "👶";
      case ReservationPriority.urgent:
        return "🚨";
    }
  }

  Color get color {
    switch (this) {
      case ReservationPriority.normal:
        return Colors.grey;
      case ReservationPriority.vip:
        return Colors.amber;
      case ReservationPriority.elderly:
        return Colors.blue.shade300;
      case ReservationPriority.newborn:
        return Colors.pink.shade300;
      case ReservationPriority.urgent:
        return Colors.red;
    }
  }

  /// Hard priority (urgent only) bypasses the active window and goes directly to the front.
  bool get isHard => level >= 4;

  static ReservationPriority fromLevel(int? level) {
    switch (level) {
      case 1:
        return ReservationPriority.vip;
      case 2:
        return ReservationPriority.elderly;
      case 3:
        return ReservationPriority.newborn;
      case 4:
        return ReservationPriority.urgent;
      default:
        return ReservationPriority.normal;
    }
  }
}
