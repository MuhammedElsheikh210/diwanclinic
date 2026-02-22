import '../../../../../../index/index_main.dart';

class ShiftSelectionDialog extends StatefulWidget {
  final List<GenericListModel> shifts;
  final Function(GenericListModel selectedShift) onConfirm;

  const ShiftSelectionDialog({
    super.key,
    required this.shifts,
    required this.onConfirm,
  });

  @override
  State<ShiftSelectionDialog> createState() => _ShiftSelectionDialogState();
}

class _ShiftSelectionDialogState extends State<ShiftSelectionDialog> {
  GenericListModel? selected;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.schedule, color: AppColors.primary),
          const SizedBox(width: 8),
          const Text("اختر الفترة"),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: widget.shifts.map((shift) {
          return RadioListTile<GenericListModel>(
            value: shift,
            groupValue: selected,
            onChanged: (value) {
              setState(() {
                selected = value;
              });
            },
            title: Text(shift.name ?? ""),
          );
        }).toList(),
      ),
      actions: [
        PrimaryTextButton(
          appButtonSize: AppButtonSize.medium,
          label: AppText(text: "تأكيد", textStyle: context.typography.mdMedium),
          onTap: () {
            if (selected == null) {
              Loader.showError("يرجى اختيار الفترة");
              return;
            }

            Get.back();
            widget.onConfirm(selected!);
          },
        ),
      ],
    );
  }
}
