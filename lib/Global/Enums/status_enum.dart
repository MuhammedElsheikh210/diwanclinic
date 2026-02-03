import 'dart:ui';

import '../../index/index_main.dart';

enum ReservationStatus {
  pending,
  approved,
  cancelledByUser,
  cancelledByAssistant,
  cancelledByDoctor,
  inProgress,
  completed,
}

extension ReservationStatusExt on ReservationStatus {
  /// ✅ English database value
  String get value {
    switch (this) {
      case ReservationStatus.pending:
        return "pending";
      case ReservationStatus.approved:
        return "approved";
      case ReservationStatus.cancelledByUser:
        return "cancelled_by_user";
      case ReservationStatus.cancelledByAssistant:
        return "cancelled_by_assistant";
      case ReservationStatus.cancelledByDoctor:
        return "cancelled_by_doctor";
      case ReservationStatus.inProgress:
        return "in_progress";
      case ReservationStatus.completed:
        return "completed";
    }
  }

  /// ✅ Arabic label for UI
  String get label {
    switch (this) {
      case ReservationStatus.pending:
        return "قيد الانتظار";
      case ReservationStatus.approved:
        return "في إنتظار الكشف";
      case ReservationStatus.cancelledByUser:
        return "أُلغي بواسطة المريض";
      case ReservationStatus.cancelledByAssistant:
        return "أُلغي بواسطة المساعد";
      case ReservationStatus.cancelledByDoctor:
        return "أُلغي بواسطة الطبيب";
      case ReservationStatus.inProgress:
        return "في الكشف";
      case ReservationStatus.completed:
        return "تم الكشف";
    }
  }

  /// ✅ Color mapping for each status
  Color get color {
    switch (this) {
      case ReservationStatus.pending:
        return Colors.orange; // waiting
      case ReservationStatus.approved:
        return AppColors.primary; // approved
      case ReservationStatus.cancelledByUser:
        return Colors.red.shade400;
      case ReservationStatus.cancelledByAssistant:
        return Colors.red.shade600;
      case ReservationStatus.cancelledByDoctor:
        return Colors.red.shade800;
      case ReservationStatus.inProgress:
        return Colors.blue; // working
      case ReservationStatus.completed:
        return AppColors.tag_icon_warning; // done
    }
  }

  /// ✅ Convert from stored DB/API string → enum
  static ReservationStatus fromValue(String value) {
    switch (value) {
      case "pending":
        return ReservationStatus.pending;
      case "approved":
        return ReservationStatus.approved;
      case "cancelled_by_user":
        return ReservationStatus.cancelledByUser;
      case "cancelled_by_assistant":
        return ReservationStatus.cancelledByAssistant;
      case "cancelled_by_doctor":
        return ReservationStatus.cancelledByDoctor;
      case "in_progress":
        return ReservationStatus.inProgress;
      case "completed":
        return ReservationStatus.completed;
      default:
        throw ArgumentError("Unknown ReservationStatus: $value");
    }
  }
}
