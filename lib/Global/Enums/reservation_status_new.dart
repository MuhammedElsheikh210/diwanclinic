import 'dart:ui';
import '../../index/index_main.dart';

/// 🔥 Final professional + correct enum
enum ReservationNewStatus {
  pending,
  approved,
  cancelledByAssistant,
  inProgress,
  completed,
}

extension ReservationStatusNewExt on ReservationNewStatus {
  /// 🔹 Database / API value (English)
  String get value {
    switch (this) {
      case ReservationNewStatus.pending:
        return "pending";
      case ReservationNewStatus.approved:
        return "approved";
      case ReservationNewStatus.cancelledByAssistant:
        return "cancelled_by_assistant";
      case ReservationNewStatus.inProgress:
        return "in_progress";
      case ReservationNewStatus.completed:
        return "completed";
    }
  }

  /// 🔹 Arabic UI Label
  String get label {
    switch (this) {
      case ReservationNewStatus.pending:
        return "في انتظار الموافقة";
      case ReservationNewStatus.approved:
        return "في إنتظار الكشف";
      case ReservationNewStatus.cancelledByAssistant:
        return "أُلغي بواسطة المساعد";
      case ReservationNewStatus.inProgress:
        return "في الكشف";
      case ReservationNewStatus.completed:
        return "تم الكشف";
    }
  }

  /// 🔹 Status Color
  Color get color {
    switch (this) {
      case ReservationNewStatus.pending:
        return Colors.orange;
      case ReservationNewStatus.approved:
        return AppColors.primary;
      case ReservationNewStatus.cancelledByAssistant:
        return Colors.red;
      case ReservationNewStatus.inProgress:
        return Colors.blue;
      case ReservationNewStatus.completed:
        return AppColors.tag_icon_warning;
    }
  }

  /// 🔥 SAFE: Convert DB value → enum (never throws)
  static ReservationNewStatus fromValue(String? value) {
    if (value == null) return ReservationNewStatus.pending;

    final v = value.trim().toLowerCase();

    switch (v) {
      case "pending":
        return ReservationNewStatus.pending;

      case "approved":
        return ReservationNewStatus.approved;

      case "cancelled_by_assistant":
      case "canceled_by_assistant":
      case "assistant_cancel":
        return ReservationNewStatus.cancelledByAssistant;

      case "in_progress":
      case "inprogress":
      case "in progress":
        return ReservationNewStatus.inProgress;

      case "completed":
      case "finished":
      case "done":
        return ReservationNewStatus.completed;

      default:
        // 🔥 Prevent crash + log once for debugging
        debugPrint(
          "⚠ Unknown ReservationNewStatus '$value' → default: pending",
        );
        return ReservationNewStatus.pending;
    }
  }
}
