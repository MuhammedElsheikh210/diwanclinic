import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../index/index.dart';
import '../../../../../index/index_main.dart';

class CancelWithReasonDialog {
  static void show({
    required BuildContext context,
    required String title,
    required String confirmText,
    required List<String> reasons,
    required Function(String selectedReason) onConfirm,
    Color confirmColor = AppColors.errorForeground,
  }) {
    showDialog(
      context: context,
      builder: (_) => _CancelWithReasonDialogWidget(
        title: title,
        confirmText: confirmText,
        reasons: reasons,
        onConfirm: onConfirm,
        confirmColor: confirmColor,
      ),
    );
  }
}

class _CancelWithReasonDialogWidget extends StatefulWidget {
  final String title;
  final String confirmText;
  final List<String> reasons;
  final Function(String selectedReason) onConfirm;
  final Color confirmColor;

  const _CancelWithReasonDialogWidget({
    required this.title,
    required this.confirmText,
    required this.reasons,
    required this.onConfirm,
    required this.confirmColor,
  });

  @override
  State<_CancelWithReasonDialogWidget> createState() =>
      _CancelWithReasonDialogWidgetState();
}

class _CancelWithReasonDialogWidgetState
    extends State<_CancelWithReasonDialogWidget> {
  int? selectedIndex;
  final TextEditingController otherController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isOtherSelected = selectedIndex == widget.reasons.length - 1;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: AppText(
        text: widget.title,
        textStyle: context.typography.lgBold.copyWith(
          color: widget.confirmColor,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...List.generate(widget.reasons.length, (index) {
              return RadioListTile<int>(
                value: index,
                groupValue: selectedIndex,
                onChanged: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
                title: AppText(
                  text: widget.reasons[index],
                  textStyle: context.typography.mdMedium,
                ),
                contentPadding: EdgeInsets.zero,
              );
            }),

            if (isOtherSelected)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: TextField(
                  controller: otherController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: "اكتب السبب هنا",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: AppText(
            text: "إلغاء",
            textStyle: context.typography.mdMedium.copyWith(
              color: AppColors.textSecondaryParagraph,
            ),
          ),
        ),
        TextButton(
          onPressed: _handleConfirm,
          child: AppText(
            text: widget.confirmText,
            textStyle: context.typography.mdBold.copyWith(
              color: widget.confirmColor,
            ),
          ),
        ),
      ],
    );
  }

  void _handleConfirm() {
    if (selectedIndex == null) {
      Loader.showError("برجاء اختيار سبب");
      return;
    }

    String reason = widget.reasons[selectedIndex!];

    if (reason == "سبب آخر") {
      if (otherController.text.trim().isEmpty) {
        Loader.showError("برجاء كتابة السبب");
        return;
      }
      reason = otherController.text.trim();
    }

    Get.back();
    widget.onConfirm(reason);
  }
}
