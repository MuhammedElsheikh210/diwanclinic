import '../../../../../index/index_main.dart';

class CalendarDropdownDoctor extends StatefulWidget {
  final Function(int, String) onDateSelected;   // 🔥 NOW INT INSTEAD OF Timestamp
  final int? initialTimestamp;
  final ReservationDoctorViewModel controller;

  const CalendarDropdownDoctor({
    super.key,
    required this.onDateSelected,
    required this.controller,
    this.initialTimestamp,
  });

  @override
  State<CalendarDropdownDoctor> createState() =>
      _CalendarDropdownDoctorState();
}

class _CalendarDropdownDoctorState extends State<CalendarDropdownDoctor> {
  late String formattedDate;

  @override
  void initState() {
    super.initState();

    final ts = widget.initialTimestamp ??
        DateTime.now().millisecondsSinceEpoch;

    formattedDate = DatesUtilis.convertTimestamp(ts);
  }

  void _openPicker() {
    final vm = Get.put(CalenderViewModel());

    vm.showIOSDatePicker(
      context,
      widget.initialTimestamp,
          (timestamp, formatted) {
        /// `timestamp` here is a Firebase Timestamp → convert it
        final intMillis = timestamp.millisecondsSinceEpoch;   // 🔥 FIX

        setState(() => formattedDate = formatted);

        /// Return (int, String)
        widget.onDateSelected(intMillis, formatted);          // 🔥 FIX
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openPicker,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.grayLight.withOpacity(0.4),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              formattedDate,
              style: context.typography.lgBold
                  .copyWith(color: AppColors.background_black),
            ),
            const SizedBox(width: 5),
            const Icon(Icons.expand_more, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
