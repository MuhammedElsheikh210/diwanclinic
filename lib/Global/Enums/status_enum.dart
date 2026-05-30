import '../../index/index_main.dart';

enum ReservationStatus {
  pending,
  approved,
  checkedIn,
  cancelledByUser,
  cancelledByAssistant,
  cancelledByDoctor,
  inProgress,
  completed,
  missed,
}

extension ReservationStatusExt on ReservationStatus {
  String get value {
    switch (this) {
      case ReservationStatus.pending:
        return "pending";
      case ReservationStatus.approved:
        return "approved";
      case ReservationStatus.checkedIn:
        return "checked_in";
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
      case ReservationStatus.missed:
        return "missed";
    }
  }

  String get label {
    switch (this) {
      case ReservationStatus.pending:
        return "قيد الانتظار";
      case ReservationStatus.approved:
        return "في إنتظار الكشف";
      case ReservationStatus.checkedIn:
        return "حضر العيادة";
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
      case ReservationStatus.missed:
        return "تغيّب";
    }
  }

  Color get color {
    switch (this) {
      case ReservationStatus.pending:
        return Colors.orange;
      case ReservationStatus.approved:
        return AppColors.primary;
      case ReservationStatus.checkedIn:
        return Colors.teal;
      case ReservationStatus.cancelledByUser:
        return Colors.red.shade400;
      case ReservationStatus.cancelledByAssistant:
        return Colors.red.shade600;
      case ReservationStatus.cancelledByDoctor:
        return Colors.red.shade800;
      case ReservationStatus.inProgress:
        return Colors.blue;
      case ReservationStatus.completed:
        return const Color(0xFF10B981);
      case ReservationStatus.missed:
        return Colors.grey;
    }
  }

  bool get isActiveInQueue =>
      this == ReservationStatus.approved ||
      this == ReservationStatus.checkedIn;

  bool get isCancelled =>
      this == ReservationStatus.cancelledByUser ||
      this == ReservationStatus.cancelledByAssistant ||
      this == ReservationStatus.cancelledByDoctor;

  static ReservationStatus fromValue(String value) {
    switch (value.trim().toLowerCase()) {
      case "pending":
        return ReservationStatus.pending;
      case "approved":
        return ReservationStatus.approved;
      case "checked_in":
        return ReservationStatus.checkedIn;
      case "cancelled_by_user":
        return ReservationStatus.cancelledByUser;
      case "cancelled_by_assistant":
        return ReservationStatus.cancelledByAssistant;
      case "cancelled_by_doctor":
        return ReservationStatus.cancelledByDoctor;
      case "in_progress":
      case "inprogress":
        return ReservationStatus.inProgress;
      case "completed":
      case "done":
        return ReservationStatus.completed;
      case "missed":
        return ReservationStatus.missed;
      default:
        return ReservationStatus.pending;
    }
  }
}
