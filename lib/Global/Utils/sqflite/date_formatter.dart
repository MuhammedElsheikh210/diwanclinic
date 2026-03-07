import 'package:intl/intl.dart';

class AppDateFormatter {
  /// 📱 UI Format
  static const String uiFormat = "dd/MM/yyyy";

  /// 🗂 Database & Firebase Format
  static const String dashFormat = "dd-MM-yyyy";

  // ============================================================
  // 🧠 Normalize → Always return UI format (dd/MM/yyyy)
  // ============================================================
  static String normalize(String? date) {
    if (date == null || date.isEmpty) {
      return DateFormat(uiFormat).format(DateTime.now());
    }

    try {
      // dd/MM/yyyy
      if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(date)) {
        final parsed = DateFormat(uiFormat).parse(date);
        return DateFormat(uiFormat).format(parsed);
      }

      // dd-MM-yyyy
      if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(date)) {
        final parsed = DateFormat(dashFormat).parse(date);
        return DateFormat(uiFormat).format(parsed);
      }

      // yyyy-MM-dd
      if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date)) {
        final parsed = DateFormat("yyyy-MM-dd").parse(date);
        return DateFormat(uiFormat).format(parsed);
      }

      return date;
    } catch (_) {
      return date;
    }
  }

  // ============================================================
  // 🔥 Firebase / DB → Always dd-MM-yyyy
  // ============================================================
  static String toDash(String? date) {
    if (date == null || date.isEmpty) {
      return DateFormat(dashFormat).format(DateTime.now());
    }

    try {
      // dd/MM/yyyy
      if (date.contains('/')) {
        final parsed = DateFormat(uiFormat).parse(date);
        return DateFormat(dashFormat).format(parsed);
      }

      // yyyy-MM-dd
      if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date)) {
        final parsed = DateFormat("yyyy-MM-dd").parse(date);
        return DateFormat(dashFormat).format(parsed);
      }

      // already dd-MM-yyyy
      if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(date)) {
        return date;
      }

      return date.replaceAll('/', '-');
    } catch (_) {
      return date.replaceAll('/', '-');
    }
  }

  // ============================================================
  // 🎯 Convert Dash → Slash (for UI inputs)
  // ============================================================
  static String toSlash(String? date) {
    if (date == null || date.isEmpty) {
      return DateFormat(uiFormat).format(DateTime.now());
    }

    try {
      if (date.contains('-')) {
        final parsed = DateFormat(dashFormat).parse(date);
        return DateFormat(uiFormat).format(parsed);
      }

      return date;
    } catch (_) {
      return date.replaceAll('-', '/');
    }
  }
}