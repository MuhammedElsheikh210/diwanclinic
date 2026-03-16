import '../../../../../../index/index_main.dart';

class CalendarDropdown extends StatefulWidget {
  final Function(Timestamp, String) onDateSelected;
  final num? initialTimestamp;
  final ReservationViewModel controller;

  const CalendarDropdown({
    Key? key,
    required this.onDateSelected,
    required this.controller,
    this.initialTimestamp,
  }) : super(key: key);

  @override
  State<CalendarDropdown> createState() => _CalendarDropdownState();
}

class _CalendarDropdownState extends State<CalendarDropdown> {
  late String formattedDate;

  @override
  void initState() {
    super.initState();
    final timestamp =
        widget.initialTimestamp ?? DateTime.now().millisecondsSinceEpoch;

    // Convert timestamp → readable date
    formattedDate = DatesUtilis.convertTimestamp(timestamp.toInt());
  }

  /// Show iOS style date picker (your existing function)
  void _showDatePicker() {
    final calenderViewModel = Get.put(CalenderViewModel());

    calenderViewModel.showIOSDatePicker(
      context,
      widget.initialTimestamp?.toInt(),
      (timestamp, selectedDate) {
        setState(() {
          formattedDate = selectedDate;
        });
        widget.onDateSelected(timestamp, selectedDate);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _showDatePicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.grayLight.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Selected date
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Text(
                      formattedDate,
                      style: context.typography.xlBold.copyWith(
                        color: AppColors.background_black,
                      ),
                    ),
                  ),

                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 22,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
