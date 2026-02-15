import '../../../../../../../index/index_main.dart';

class ReservationCancelReasonSheet extends StatefulWidget {
  final ReservationModel reservation;
  final ReservationViewModel controller;

  const ReservationCancelReasonSheet({
    super.key,
    required this.reservation,
    required this.controller,
  });

  @override
  State<ReservationCancelReasonSheet> createState() =>
      _ReservationCancelReasonSheetState();
}

class _ReservationCancelReasonSheetState
    extends State<ReservationCancelReasonSheet> {
  final TextEditingController otherReasonController = TextEditingController();

  int? selectedIndex;

  final List<String> reasons = [
    "المريض لم يحضر",
    "الدكتور في مؤتمر",
    "ظرف طارئ للطبيب",
    "سبب آخر",
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
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

            ...List.generate(reasons.length, (index) {
              return RadioListTile<int>(
                value: index,
                groupValue: selectedIndex,
                onChanged: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
                title: Text(reasons[index], style: context.typography.mdMedium),
              );
            }),

            if (selectedIndex == reasons.length - 1)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: TextField(
                  controller: otherReasonController,
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
                onTap: _confirmCancel,
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _confirmCancel() async {
    if (selectedIndex == null) {
      Loader.showError("برجاء اختيار سبب");
      return;
    }

    String reason = reasons[selectedIndex!];

    if (reason == "سبب آخر") {
      if (otherReasonController.text.trim().isEmpty) {
        Loader.showError("برجاء كتابة السبب");
        return;
      }
      reason = otherReasonController.text.trim();
    }

    Navigator.pop(context);

    await widget.controller.changeReservationStatus(
      reservation: widget.reservation,
      newStatus: ReservationStatus.cancelledByAssistant,
      cancelReason: reason,

    );
  }
}
