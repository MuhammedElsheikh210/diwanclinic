import '../../../../../index/index_main.dart';

class CalendarDropdownIncome extends StatefulWidget {
  final Function(int, String) onDateSelected;
  final int? initialTimestamp;

  const CalendarDropdownIncome({
    super.key,
    required this.onDateSelected,
    this.initialTimestamp,
  });

  @override
  State<CalendarDropdownIncome> createState() =>
      _CalendarDropdownIncomeState();
}

class _CalendarDropdownIncomeState extends State<CalendarDropdownIncome> {
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
        final intMillis = timestamp.millisecondsSinceEpoch;

        setState(() => formattedDate = formatted);

        widget.onDateSelected(intMillis, formatted);
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
              style: context.typography.lgBold.copyWith(
                color: AppColors.background_black,
              ),
            ),
            const SizedBox(width: 5),
            const Icon(Icons.expand_more, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
