import '../../../../../index/index_main.dart';

/// Custom formatter to convert Arabic digits (٠١٢٣٤٥٦٧٨٩) to English digits (0123456789).
class ArabicToEnglishDigitsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text.replaceAllMapped(RegExp(r'[٠١٢٣٤٥٦٧٨٩]'), (
      match,
    ) {
      switch (match.group(0)) {
        case '٠':
          return '0';
        case '١':
          return '1';
        case '٢':
          return '2';
        case '٣':
          return '3';
        case '٤':
          return '4';
        case '٥':
          return '5';
        case '٦':
          return '6';
        case '٧':
          return '7';
        case '٨':
          return '8';
        case '٩':
          return '9';
        default:
          return match.group(0)!;
      }
    });
    return newValue.copyWith(text: newText, selection: newValue.selection);
  }
}

class CustomInputField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final String? prefixIcon;
  final String? sufixIcon;
  final TextInputType keyboardType;
  final FocusNode focusNode;
  final String? Function(String?) validator;
  final ValueChanged<String>? voidCallbackAction;
  final bool obscureText;
  final bool? show_asterisc;
  final bool? enable;
  final double? padding_horizontal;

  const CustomInputField({
    Key? key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.prefixIcon,
    this.enable,
    this.sufixIcon,
    this.show_asterisc,
    this.voidCallbackAction,
    this.padding_horizontal,
    required this.keyboardType,
    required this.focusNode,
    required this.validator,
    this.obscureText = false,
  }) : super(key: key);

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {

  @override
  Widget build(BuildContext context) {
    // Add input formatter for numeric keyboard types
    List<TextInputFormatter>? inputFormatters;
    if (widget.keyboardType == TextInputType.number ||
        (widget.keyboardType.toString().contains('number'))) {
      inputFormatters = [ArabicToEnglishDigitsFormatter()];
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.padding_horizontal ?? 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: Row(
              children: [
                // Show asterisk if needed (assuming null means show)
                Visibility(
                  visible: widget.show_asterisc == null,
                  child: Text(
                    "* ",
                    style: TextStyle(color: ColorMappingImpl().errorTextColor),
                  ),
                ),
                AppText(
                  text: widget.label,

                  textStyle: context.typography.mdRegular.copyWith(
                    color: ColorMappingImpl().textLabel,
                  ),
                ),
              ],
            ),
          ),
          AppTextField(
            controller: widget.controller,
            hintText: widget.hintText,
            keyboardType: widget.keyboardType,
            focusNode: widget.focusNode,
            obscureText: widget.obscureText,
            prefixIcon:
                widget.prefixIcon != null && widget.prefixIcon!.isNotEmpty
                    ? Image.asset(widget.prefixIcon!)
                    : null,
            suffixIcon:
                widget.sufixIcon != null && widget.sufixIcon!.isNotEmpty
                    ? Image.asset(widget.sufixIcon!)
                    : null,
            validator: widget.validator,
            onChanged: widget.voidCallbackAction,
            enabled: widget.enable ?? true,
            // Pass the formatter if applicable
            formaters: inputFormatters,
          ),
        ],
      ),
    );
  }
}
