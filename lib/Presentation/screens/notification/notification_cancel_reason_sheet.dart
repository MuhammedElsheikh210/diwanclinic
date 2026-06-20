import '../../../../index/index_main.dart';

class NotificationCancelReasonSheet extends StatefulWidget {
  final Future<void> Function(String reason) onConfirm;

  const NotificationCancelReasonSheet({super.key, required this.onConfirm});

  @override
  State<NotificationCancelReasonSheet> createState() =>
      _NotificationCancelReasonSheetState();
}

class _NotificationCancelReasonSheetState
    extends State<NotificationCancelReasonSheet> {
  final TextEditingController _otherController = TextEditingController();
  int? _selectedIndex;

  final List<String> _reasons = [
    "المريض لم يحضر",
    "الدكتور في مؤتمر",
    "ظرف طارئ للطبيب",
    "سبب آخر",
  ];

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 45,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          Text("سبب الإلغاء", style: context.typography.xlBold),
          const SizedBox(height: 16),
          ...List.generate(_reasons.length, (index) {
            return RadioListTile<int>(
              value: index,
              groupValue: _selectedIndex,
              onChanged: (value) => setState(() => _selectedIndex = value),
              title: Text(_reasons[index], style: context.typography.mdMedium),
            );
          }),
          if (_selectedIndex == _reasons.length - 1)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextField(
                controller: _otherController,
                decoration: const InputDecoration(
                  hintText: "اكتب السبب هنا",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: PrimaryTextButton(
              appButtonSize: AppButtonSize.large,
              customBackgroundColor: AppColors.errorForeground,
              label: AppText(
                text: "تأكيد الإلغاء",
                textStyle: context.typography.mdBold.copyWith(
                  color: Colors.white,
                ),
              ),
              onTap: _confirm,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void _confirm() async {
    if (_selectedIndex == null) {
      Loader.showError("برجاء اختيار سبب");
      return;
    }

    String reason = _reasons[_selectedIndex!];

    if (reason == "سبب آخر") {
      if (_otherController.text.trim().isEmpty) {
        Loader.showError("برجاء كتابة السبب");
        return;
      }
      reason = _otherController.text.trim();
    }

    Navigator.pop(context);
    await widget.onConfirm(reason);
  }
}
