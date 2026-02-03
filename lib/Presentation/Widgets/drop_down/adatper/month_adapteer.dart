

import 'package:diwanclinic/Data/Models/lists/generic_list_model.dart';

class MonthAdapter {
  static List<GenericListModel> generateMonths({int count = 12}) {
    final now = DateTime.now();
    final List<GenericListModel> months = [];

    for (int i = 0; i < count; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      final key = "${date.year}-${date.month}";
      final title = "${date.month}-${date.year}"; // 8-2025 style

      months.add(GenericListModel(key: key, name: title));
    }
    return months;
  }
}
