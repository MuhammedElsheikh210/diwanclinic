
import '../../../../index/index_main.dart';

class OtpCustomWidget extends StatefulWidget {
  final OtpViewModel? controller;
  final Function(String)? onOtpEntered;

  const OtpCustomWidget({
    Key? key,
    this.controller,
    this.onOtpEntered,
  }) : super(key: key);

  @override
  State<OtpCustomWidget> createState() => _OtpCustomWidgetState();
}

class _OtpCustomWidgetState extends State<OtpCustomWidget> {
  final List<TextEditingController> textControllers =
  List.generate(4, (index) => TextEditingController());
  final List<FocusNode> focusNodes = [];

  @override
  void initState() {
    super.initState();
    // Initialize focus nodes
    focusNodes.addAll([
      widget.controller?.myFocusNode ?? FocusNode(),
      widget.controller?.myFocusNode2 ?? FocusNode(),
      widget.controller?.myFocusNode3 ?? FocusNode(),
      widget.controller?.myFocusNode4 ?? FocusNode(),
    ]);
  }

  @override
  void dispose() {
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Reset OTP fields if the previous attempt was incorrect
    if (widget.controller?.isFill == false) {
      for (var controller in textControllers) {
        controller.clear();
      }
      widget.controller?.code = "";
      widget.controller?.isFill = true;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        textControllers.length,
            (index) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10.0),
            width: 50.0,
            height: 50.0,
            decoration: BoxDecoration(
              color: ColorResources.COLOR_GREY50.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: TextField(
              style: GoogleFonts.getFont(Strings.fontname, fontSize: 17),
              controller: textControllers[index],
              focusNode: focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              onChanged: (value) => _handleOtpInput(value, index),
              decoration: InputDecoration(
                counterText: "",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: ColorResources.COLOR_GREY70),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: ColorResources.COLOR_red),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Handles OTP input and manages navigation between fields
  void _handleOtpInput(String value, int index) {
    if (value.isNotEmpty) {
      // Handle auto-complete for OTP (when entered at once)
      if (value.length == 4 && index == 0) {
        for (int i = 0; i < value.length; i++) {
          textControllers[i].text = value[i];
        }
        widget.onOtpEntered?.call(value);
        FocusManager.instance.primaryFocus?.unfocus();
      } else if (index < textControllers.length - 1) {
        // Navigate to the next field
        textControllers[index].text = value[0];
        FocusScope.of(context).nextFocus();
      } else {
        // Populate the last field and validate OTP
        textControllers[index].text = value[0];
        _submitOtp();
      }
    }
  }

  /// Collects and submits the entered OTP
  void _submitOtp() {
    FocusManager.instance.primaryFocus?.unfocus(); // Unfocus the keyboard
    final enteredOtp = textControllers.map((controller) => controller.text).join();
    widget.onOtpEntered?.call(enteredOtp);
  }
}
