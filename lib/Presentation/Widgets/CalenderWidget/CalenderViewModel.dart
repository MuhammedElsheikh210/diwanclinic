import 'package:flutter/cupertino.dart';

import '../../../index/index_main.dart';

class CalenderViewModel extends GetxController {
  String? _selectedDate;
  Timestamp? _selectedTimestamp;

  void showIOSDatePicker(
    BuildContext context,
    int? timestamp,
    Function(Timestamp, String) onDateSelected,
  ) {
    final DateTime initial = timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : DateTime.now();

    DateTime tempDate = initial;

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        color: Colors.white,
        height: 330,
        child: Column(
          children: [
            // 🔵 زر DONE
            InkWell(
              onTap: () {

                final ts = Timestamp.fromDate(tempDate);
                final formatted = _formatDate(tempDate);
                onDateSelected(ts, formatted);
                Navigator.of(context).pop(); // close picker
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 15,
                ),
                alignment: Alignment.centerRight,
                child: Text(
                  "تم",
                  style: context.typography.mdMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),

            const Divider(height: 0),

            // 🔵 Date Picker
            SizedBox(
              height: 250,
              child: CupertinoDatePicker(
                initialDateTime: initial,
                mode: CupertinoDatePickerMode.date,
                onDateTimeChanged: (DateTime date) {
                  tempDate = date; // نخزن بس.. مش نرجّع قيم
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {

    final String day = date.day < 10 ? "0${date.day}" : "${date.day}";
    final String month = date.month < 10 ? "0${date.month}" : "${date.month}";
    return "$day-$month-${date.year}";
  }
}
