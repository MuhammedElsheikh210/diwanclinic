/// Reasons why a patient's queue position changed.
/// Stored in Firebase and shown to the patient as a human-readable message.
enum QueueChangeReason {
  /// المريض سجّل حضوره في العيادة
  checkedIn,

  /// تم تغيير أولوية المريض (VIP / كبير سن / مستعجل …)
  priorityAssigned,

  /// تم تقديم المريض يدويًا بواسطة المساعد
  manualPromote,

  /// تم إدراج حالة طارئة
  emergencyInserted,

  /// تم إدراج حالة حديث ولادة
  newbornInserted,

  /// تم إعادة إدراج المريض بعد غياب
  missedReturned,

  /// تغيّرت نافذة الكشف (انتقل الطبيب لرقم جديد)
  windowShift,
}

extension QueueChangeReasonExt on QueueChangeReason {
  /// رسالة مختصرة تُعرض للمريض في التطبيق.
  String get patientMessage {
    switch (this) {
      case QueueChangeReason.checkedIn:
        return 'تم تسجيل حضورك — ستُنادى قريبًا';
      case QueueChangeReason.priorityAssigned:
        return 'تم تحديث أولويتك في الطابور';
      case QueueChangeReason.manualPromote:
        return 'تم تقديمك في الطابور بواسطة المساعد';
      case QueueChangeReason.emergencyInserted:
        return 'تم إدراج حالة طارئة — قد يتأخر دورك قليلًا';
      case QueueChangeReason.newbornInserted:
        return 'تم إدراج حالة حديث ولادة — ستتأخر قليلًا';
      case QueueChangeReason.missedReturned:
        return 'تم إعادة ترتيبك بعد الغياب';
      case QueueChangeReason.windowShift:
        return 'تم تحديث نافذة الكشف';
    }
  }

  /// بادج قصير يُعرض للمساعد لتوضيح سبب تغيّر الترتيب.
  String get assistantBadge {
    switch (this) {
      case QueueChangeReason.checkedIn:
        return 'سجّل حضوره';
      case QueueChangeReason.priorityAssigned:
        return 'أولوية طبية';
      case QueueChangeReason.manualPromote:
        return 'تقديم يدوي';
      case QueueChangeReason.emergencyInserted:
        return 'حالة طارئة';
      case QueueChangeReason.newbornInserted:
        return 'حديث ولادة';
      case QueueChangeReason.missedReturned:
        return 'رجع بعد غياب';
      case QueueChangeReason.windowShift:
        return 'تحديث الطابور';
    }
  }

  /// رسالة داخلية لسجلات النظام / الـ analytics.
  String get systemLabel {
    switch (this) {
      case QueueChangeReason.checkedIn:
        return 'checked_in';
      case QueueChangeReason.priorityAssigned:
        return 'priority_assigned';
      case QueueChangeReason.manualPromote:
        return 'manual_promote';
      case QueueChangeReason.emergencyInserted:
        return 'emergency_inserted';
      case QueueChangeReason.newbornInserted:
        return 'newborn_inserted';
      case QueueChangeReason.missedReturned:
        return 'missed_returned';
      case QueueChangeReason.windowShift:
        return 'window_shift';
    }
  }

  static QueueChangeReason fromLabel(String? label) {
    switch (label) {
      case 'checked_in':
        return QueueChangeReason.checkedIn;
      case 'priority_assigned':
        return QueueChangeReason.priorityAssigned;
      case 'manual_promote':
        return QueueChangeReason.manualPromote;
      case 'emergency_inserted':
        return QueueChangeReason.emergencyInserted;
      case 'newborn_inserted':
        return QueueChangeReason.newbornInserted;
      case 'missed_returned':
        return QueueChangeReason.missedReturned;
      case 'window_shift':
        return QueueChangeReason.windowShift;
      default:
        return QueueChangeReason.windowShift;
    }
  }
}
