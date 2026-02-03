import 'package:intl/intl.dart';

class DatesUtilis {
  static DateTime? parseDate(String date) {
    try {
      return DateFormat('dd/MM/yyyy').parse(date);
    } catch (e) {
      return null;
    }
  }

  static T convertTimestamp<T>(int timestamp) {

    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

    // ✅ لو النوع String
    if (T == String) {
      return DateFormat('dd/MM/yyyy').format(dateTime) as T;
    }

    // ✅ لو النوع DateTime
    if (T == DateTime) {
      return dateTime as T;
    }

    // ✅ لو النوع dynamic أو مش متحدد
    if (T == dynamic) {
      // الافتراضي String (أكتر استخدام في UI)
      return DateFormat('dd/MM/yyyy').format(dateTime) as T;
    }

    // ❌ أي نوع تاني
    throw UnsupportedError(
      "convertTimestamp does not support type $T",
    );
  }


  static void checkDateEndBiggerThanStart({
    required String startDateText,
    required String endDateText,
    required Function(bool isError, String? errorMessage) onValidationResult,
  }) {
    if (startDateText.isNotEmpty && endDateText.isNotEmpty) {
      final DateTime? startDate = parseDate(startDateText);
      final DateTime? endDate = parseDate(endDateText);

      if (startDate != null && endDate != null) {
        if (endDate.isBefore(startDate)) {
          // End date is before start date
          onValidationResult(
            true,
            "تاريخ النهاية يجب أن يكون بعد تاريخ البداية",
          );
        } else {
          // Calculate the duration between the two dates
          final Duration duration = endDate.difference(startDate);

          if (duration.inDays < 30) {
            // Duration is less than 30 days
            onValidationResult(true, "المدة يجب أن تكون على الأقل 30 يومًا");
          } else if (duration.inDays > 365) {
            // Duration is more than 1 year
            onValidationResult(true, "المدة يجب أن لا تتجاوز سنة واحدة");
          } else {
            // Dates and duration are valid
            onValidationResult(false, null); // No error
          }
        }
      } else {
        // One or both dates could not be parsed
        onValidationResult(true, "تأكد من صحة التواريخ المدخلة");
      }
    }
  }

  /// Check if `third` is between `first` and `second`
  static bool isDateBetween({
    required DateTime first,
    required DateTime second,
    required DateTime third,
  }) {
    return third.isAfter(first) && third.isBefore(second) ||
        third.isAtSameMomentAs(first) ||
        third.isAtSameMomentAs(second);
  }
}
