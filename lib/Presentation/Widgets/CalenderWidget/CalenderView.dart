import '../../../index/index_main.dart';

class CalenderWidget extends StatefulWidget {
  final Function(Timestamp, String) onDateSelected;
  final String hintText;
  final num? initialTimestamp;

  // Removed showCalenerSwitch since it's no longer needed.

  const CalenderWidget({
    Key? key,
    required this.onDateSelected,
    required this.hintText,
    this.initialTimestamp,
  }) : super(key: key);

  @override
  State<CalenderWidget> createState() => _CalenderWidgetState();
}

class _CalenderWidgetState extends State<CalenderWidget> {
  late final TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();

    // Prepopulate the date field if initialTimestamp is provided.
    if (widget.initialTimestamp != null) {
      _textEditingController.text = DatesUtilis.convertTimestamp(
        widget.initialTimestamp?.toInt() ?? 0,
      );
    }
  }

  @override
  void didUpdateWidget(covariant CalenderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialTimestamp != oldWidget.initialTimestamp &&
        widget.initialTimestamp != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        final newText = DatesUtilis.convertTimestamp<String>(
          widget.initialTimestamp!.toInt(),
        );

        if (_textEditingController.text != newText) {
          _textEditingController.text = newText;
        }
      });
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  /// Displays the standard iOS date picker.
  void _showIOSDatePicker(BuildContext context, {int? initialdata}) {
    final calenderViewModel = Get.put(CalenderViewModel());
    calenderViewModel.showIOSDatePicker(context, initialdata, (
      timestamp,
      formattedDate,
    ) {
      widget.onDateSelected(timestamp, formattedDate);
      _textEditingController.text = formattedDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _showIOSDatePicker(
            context,
            initialdata: widget.initialTimestamp?.toInt(),
          ),
          child: TextFormField(
            controller: _textEditingController,
            style: context.typography.mdMedium.copyWith(
              color: AppColors.textDisplay,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: context.typography.smMedium,
              suffixIcon: const Icon(
                Icons.date_range,
                color: AppColors.textDisplay,
              ),
              filled: true,
              fillColor: ColorResources.COLOR_GREY20.withValues(alpha: 0.2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.grey),
              ),
            ),
            enabled: false,
          ),
        ),
      ],
    );
  }
}
