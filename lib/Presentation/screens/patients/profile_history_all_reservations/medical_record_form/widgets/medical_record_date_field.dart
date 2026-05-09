import '../../../../../../index/index_main.dart';

class MedicalRecordDateField extends StatefulWidget {
  final String hint;

  final TextEditingController controller;

  const MedicalRecordDateField({
    super.key,
    required this.hint,
    required this.controller,
  });

  @override
  State<MedicalRecordDateField> createState() => _MedicalRecordDateFieldState();
}

class _MedicalRecordDateFieldState extends State<MedicalRecordDateField> {
  /// =========================================================
  /// IOS DATE PICKER
  /// =========================================================
  void _showIOSDatePicker() {
    final calenderViewModel = Get.put(CalenderViewModel());

    int? initialTimestamp;

    try {
      if (widget.controller.text.isNotEmpty) {
        initialTimestamp =
            DateTime.parse(widget.controller.text).millisecondsSinceEpoch;
      }
    } catch (_) {}

    calenderViewModel.showIOSDatePicker(context, initialTimestamp, (
      timestamp,
      formattedDate,
    ) {
      widget.controller.text = formattedDate;

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),

        onTap: _showIOSDatePicker,

        child: AbsorbPointer(
          child: AppTextField(
            hintText: widget.hint,

            controller: widget.controller,

            keyboardType: TextInputType.datetime,

            suffixIcon: const Icon(
              Icons.date_range,
              color: AppColors.textDisplay,
            ),

            validator: (String? p1) {},

            focusNode: FocusNode(),
          ),
        ),
      ),
    );
  }
}
