import '../../../../../../index/index_main.dart';

class CalendarVisitesDropdown extends StatefulWidget {
  final Function(Timestamp, String) onDateSelected;
  final num? initialTimestamp;

  const CalendarVisitesDropdown({
    Key? key,
    required this.onDateSelected,
    this.initialTimestamp,
  }) : super(key: key);

  @override
  State<CalendarVisitesDropdown> createState() =>
      _CalendarVisitesDropdownState();
}

class _CalendarVisitesDropdownState extends State<CalendarVisitesDropdown> {
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
        padding: const EdgeInsets.all(10),
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
