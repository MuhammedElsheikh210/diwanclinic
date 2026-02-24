import '../../../../../../index/index_main.dart';

class ShiftSelectionDialog extends StatefulWidget {
  final List<GenericListModel> shifts;
  final GenericListModel? initialSelected;
  final Function(GenericListModel selectedShift) onSelect;

  const ShiftSelectionDialog({
    super.key,
    required this.shifts,
    required this.onSelect,
    this.initialSelected,
  });

  @override
  State<ShiftSelectionDialog> createState() =>
      _ShiftSelectionDialogState();
}

class _ShiftSelectionDialogState
    extends State<ShiftSelectionDialog> {

  late GenericListModel? selected;

  @override
  void initState() {
    super.initState();
    selected = widget.initialSelected; // ✅ يظهر القديم
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 24),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          /// 🔹 Title
          Row(
            children: [
              const Icon(Icons.schedule,
                  color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                "اختر الفترة",
                style: context.typography.mdMedium,
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// 🔹 Shift List
          ...widget.shifts.map((shift) {
            final isSelected = selected?.key == shift.key;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selected = shift;
                });

                Future.delayed(
                  const Duration(milliseconds: 150),
                      () {
                    Get.back();
                    widget.onSelect(shift);
                  },
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.borderNeutralPrimary
                        .withValues(alpha: 0.4),
                    width: 1.4,
                  ),
                ),
                child: Row(
                  children: [

                    /// ✔ Selection Icon
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.grayMedium,
                          width: 2,
                        ),
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                          size: 14,
                          color: Colors.white)
                          : null,
                    ),

                    const SizedBox(width: 12),

                    /// Shift Name
                    Expanded(
                      child: Text(
                        shift.name ?? "",
                        style: context.typography.mdMedium.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.background_black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}