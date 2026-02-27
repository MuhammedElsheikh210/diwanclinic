import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../index/index_main.dart';

class TimeWidget extends StatelessWidget {
  final String hintText;
  final int? initialTimestamp;
  final Function(DateTime time, String formattedTime) onTimeSelected;

  const TimeWidget({
    super.key,
    required this.hintText,
    required this.onTimeSelected,
    this.initialTimestamp,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime initial = initialTimestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(initialTimestamp!)
        : DateTime.now();

    final String displayText = initialTimestamp != null
        ? DateFormat("HH:mm").format(initial)
        : hintText;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _showIOSPicker(context, initial),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.borderNeutralPrimary.withOpacity(0.6),
          ),
        ),
        child: Text(displayText, style: context.typography.mdMedium),
      ),
    );
  }

  void _showIOSPicker(BuildContext context, DateTime initial) {
    DateTime tempPickedTime = initial;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height: 320,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              /// 🔹 Top Bar (iOS style)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text("إلغاء"),
                    ),
                    Text("اختر الوقت", style: context.typography.mdBold),
                    TextButton(
                      onPressed: () {
                        final formatted = DateFormat(
                          "HH:mm",
                        ).format(tempPickedTime);

                        onTimeSelected(tempPickedTime, formatted);
                        Get.back();
                      },
                      child: const Text("تم"),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              /// 🔹 iOS Wheel Picker
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  initialDateTime: initial,
                  onDateTimeChanged: (dateTime) {
                    tempPickedTime = dateTime;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
