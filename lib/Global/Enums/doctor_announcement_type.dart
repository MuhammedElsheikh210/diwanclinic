import 'package:flutter/material.dart';

enum DoctorAnnouncementType {
  arrived,
  delayed,
  cancelledToday,
  temporaryBreak,
  resumed,
}

extension DoctorAnnouncementTypeExt on DoctorAnnouncementType {
  String get value {
    switch (this) {
      case DoctorAnnouncementType.arrived:
        return 'arrived';
      case DoctorAnnouncementType.delayed:
        return 'delayed';
      case DoctorAnnouncementType.cancelledToday:
        return 'cancelled_today';
      case DoctorAnnouncementType.temporaryBreak:
        return 'temporary_break';
      case DoctorAnnouncementType.resumed:
        return 'resumed';
    }
  }

  String get arabicLabel {
    switch (this) {
      case DoctorAnnouncementType.arrived:
        return 'وصل الدكتور';
      case DoctorAnnouncementType.delayed:
        return 'الدكتور متأخر';
      case DoctorAnnouncementType.cancelledToday:
        return 'الدكتور معتذر اليوم';
      case DoctorAnnouncementType.temporaryBreak:
        return 'خرج مؤقتاً';
      case DoctorAnnouncementType.resumed:
        return 'رجع واستأنف';
    }
  }

  String get notificationTitle {
    switch (this) {
      case DoctorAnnouncementType.arrived:
        return '✅ وصل الدكتور';
      case DoctorAnnouncementType.delayed:
        return '⏳ الدكتور متأخر';
      case DoctorAnnouncementType.cancelledToday:
        return '❌ الدكتور معتذر اليوم';
      case DoctorAnnouncementType.temporaryBreak:
        return '⏸️ الدكتور خرج مؤقتاً';
      case DoctorAnnouncementType.resumed:
        return '▶️ الدكتور رجع واستأنف';
    }
  }

  Color get color {
    switch (this) {
      case DoctorAnnouncementType.arrived:
        return const Color(0xFF10B981);
      case DoctorAnnouncementType.delayed:
        return const Color(0xFFF97316);
      case DoctorAnnouncementType.cancelledToday:
        return const Color(0xFFEF4444);
      case DoctorAnnouncementType.temporaryBreak:
        return const Color(0xFFF59E0B);
      case DoctorAnnouncementType.resumed:
        return const Color(0xFF3B82F6);
    }
  }

  IconData get icon {
    switch (this) {
      case DoctorAnnouncementType.arrived:
        return Icons.check_circle_outline_rounded;
      case DoctorAnnouncementType.delayed:
        return Icons.schedule_rounded;
      case DoctorAnnouncementType.cancelledToday:
        return Icons.cancel_outlined;
      case DoctorAnnouncementType.temporaryBreak:
        return Icons.pause_circle_outline_rounded;
      case DoctorAnnouncementType.resumed:
        return Icons.play_circle_outline_rounded;
    }
  }

  bool get requiresReason {
    return this == DoctorAnnouncementType.delayed ||
        this == DoctorAnnouncementType.cancelledToday ||
        this == DoctorAnnouncementType.temporaryBreak;
  }

  bool get isUnavailable {
    return this == DoctorAnnouncementType.cancelledToday ||
        this == DoctorAnnouncementType.temporaryBreak;
  }

  static DoctorAnnouncementType fromValue(String? value) {
    switch (value) {
      case 'arrived':
        return DoctorAnnouncementType.arrived;
      case 'delayed':
        return DoctorAnnouncementType.delayed;
      case 'cancelled_today':
        return DoctorAnnouncementType.cancelledToday;
      case 'temporary_break':
        return DoctorAnnouncementType.temporaryBreak;
      case 'resumed':
        return DoctorAnnouncementType.resumed;
      default:
        return DoctorAnnouncementType.arrived;
    }
  }
}
