import 'package:intl/intl.dart';

class AppDateFormatter {

  static const String format = "dd/MM/yyyy";

  static String normalize(String? date) {

    if (date == null || date.isEmpty) {
      return DateFormat(format).format(DateTime.now());
    }

    try {

      // لو already صحيح
      if (date.contains("/")) {
        final parsed = DateFormat("dd/MM/yyyy").parse(date);
        return DateFormat(format).format(parsed);
      }

      // لو جاي 2026-03-04
      if (date.contains("-") && date.startsWith("20")) {
        final parsed = DateFormat("yyyy-MM-dd").parse(date);
        return DateFormat(format).format(parsed);
      }

      // لو جاي 04-03-2026
      if (date.contains("-")) {
        final parsed = DateFormat("dd-MM-yyyy").parse(date);
        return DateFormat(format).format(parsed);
      }

      return date;

    } catch (_) {
      return date;
    }
  }

}