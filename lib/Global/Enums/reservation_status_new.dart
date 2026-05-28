import 'dart:ui';
import '../../index/index_main.dart';

enum ReservationNewStatus {
  pending,
  approved,
  checkedIn,
  cancelledByAssistant,
  cancelledByUser,
  inProgress,
  completed,
  missed,
}

extension ReservationStatusNewExt on ReservationNewStatus {
  String get value {
    switch (this) {
      case ReservationNewStatus.pending:
        return "pending";
      case ReservationNewStatus.approved:
        return "approved";
      case ReservationNewStatus.checkedIn:
        return "checked_in";
      case ReservationNewStatus.cancelledByAssistant:
        return "cancelled_by_assistant";
      case ReservationNewStatus.cancelledByUser:
        return "cancelled_by_user";
      case ReservationNewStatus.inProgress:
        return "in_progress";
      case ReservationNewStatus.completed:
        return "completed";
      case ReservationNewStatus.missed:
        return "missed";
    }
  }

  String get label {
    switch (this) {
      case ReservationNewStatus.pending:
        return "في انتظار الموافقة";
      case ReservationNewStatus.approved:
        return "في إنتظار الكشف";
      case ReservationNewStatus.checkedIn:
        return "حضر العيادة";
      case ReservationNewStatus.cancelledByAssistant:
        return "أُلغي بواسطة المساعد";
      case ReservationNewStatus.cancelledByUser:
        return "أُلغي بواسطة المستخدم";
      case ReservationNewStatus.inProgress:
        return "في الكشف";
      case ReservationNewStatus.completed:
        return "تم الكشف";
      case ReservationNewStatus.missed:
        return "تغيّب";
    }
  }

  Color get color {
    switch (this) {
      case ReservationNewStatus.pending:
        return Colors.orange;
      case ReservationNewStatus.approved:
        return AppColors.primary;
      case ReservationNewStatus.checkedIn:
        return Colors.teal;
      case ReservationNewStatus.cancelledByAssistant:
      case ReservationNewStatus.cancelledByUser:
        return Colors.red;
      case ReservationNewStatus.inProgress:
        return Colors.blue;
      case ReservationNewStatus.completed:
        return AppColors.tag_icon_warning;
      case ReservationNewStatus.missed:
        return Colors.grey;
    }
  }

  static ReservationNewStatus fromValue(String? value) {
    if (value == null) return ReservationNewStatus.pending;

    switch (value.trim().toLowerCase()) {
      case "pending":
        return ReservationNewStatus.pending;
      case "approved":
        return ReservationNewStatus.approved;
      case "checked_in":
        return ReservationNewStatus.checkedIn;
      case "cancelled_by_assistant":
      case "canceled_by_assistant":
      case "assistant_cancel":
        return ReservationNewStatus.cancelledByAssistant;
      case "cancelled_by_user":
      case "canceled_by_user":
      case "user_cancel":
        return ReservationNewStatus.cancelledByUser;
      case "in_progress":
      case "inprogress":
      case "in progress":
        return ReservationNewStatus.inProgress;
      case "completed":
      case "finished":
      case "done":
        return ReservationNewStatus.completed;
      case "missed":
        return ReservationNewStatus.missed;
      default:
        return ReservationNewStatus.pending;
    }
  }
}
