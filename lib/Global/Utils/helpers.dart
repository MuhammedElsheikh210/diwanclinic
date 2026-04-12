import 'package:intl/intl.dart';

String convertArabicToEnglishNumbers(String input) {
  const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

  for (int i = 0; i < arabic.length; i++) {
    input = input.replaceAll(arabic[i], english[i]);
  }
  return input;
}

String toDashFormat(DateTime date) {
  return DateFormat('dd-MM-yyyy').format(date);
}

String normalizeToDashDate(String? date) {
  if (date == null || date.isEmpty) {
    return DateFormat('dd-MM-yyyy').format(DateTime.now());
  }

  try {
    // dd/MM/yyyy
    if (date.contains('/')) {
      final parsed = DateFormat('dd/MM/yyyy').parse(date);
      return DateFormat('dd-MM-yyyy').format(parsed);
    }

    // yyyy-MM-dd
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date)) {
      final parsed = DateFormat('yyyy-MM-dd').parse(date);
      return DateFormat('dd-MM-yyyy').format(parsed);
    }

    // dd-MM-yyyy (already correct)
    if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(date)) {
      return date;
    }

    // fallback
    final parsed = DateTime.tryParse(date);
    if (parsed != null) {
      return DateFormat('dd-MM-yyyy').format(parsed);
    }

    return date;
  } catch (_) {
    return DateFormat('dd-MM-yyyy').format(DateTime.now());
  }
}
