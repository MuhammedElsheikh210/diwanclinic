import '../../../../../../index/index_main.dart';

class MedicalRecordInputField extends StatelessWidget {
  final String hint;

  final TextEditingController controller;

  final TextInputType keyboardType;

  final int maxLines;

  final FocusNode focusNode;

  const MedicalRecordInputField({
    super.key,
    required this.hint,
    required this.controller,
    required this.focusNode,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      hintText: hint,

      controller: controller,

      keyboardType: keyboardType,

      focusNode: focusNode,

      textInputAction:
          maxLines > 1 ? TextInputAction.newline : TextInputAction.next,

      validator: InputValidators.combine([]),
    );
  }
}
