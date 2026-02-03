// ignore_for_file: must_be_immutable

import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../../../index/index_main.dart';

class PhoneWidget extends StatefulWidget {
  final GlobalKey<FormState> globalKeyPhone;
  final FocusNode myFocusNode;
  final bool? isenable;
  final Color textColor;
  final Function(String completeNumber, String number, String countryCode)
  onChange;
  final TextEditingController? textEditingController;

  const PhoneWidget({
    Key? key,
    required this.globalKeyPhone,
    required this.myFocusNode,
    this.isenable,
    required this.textColor,
    this.textEditingController,
    required this.onChange,
  }) : super(key: key);

  @override
  State<PhoneWidget> createState() => _PhoneWidgetState();
}

class _PhoneWidgetState extends State<PhoneWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.textEditingController ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.textEditingController == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Form(
        key: widget.globalKeyPhone,
        child: IntlPhoneField(
          enabled: widget.isenable != null ? false : true,
          controller: _controller,
          pickerDialogStyle: PickerDialogStyle(
            backgroundColor: ColorResources.COLOR_white,
            searchFieldCursorColor: ColorResources.COLOR_Primary,
          ),
          searchText: "Search country".tr,
          validator: (value) {
            if (value == null) {
              return "need data";
            }
            return null;
          },
          cursorColor: ColorResources.COLOR_Primary,
          decoration: InputDecoration(
              fillColor: ColorResources.COLOR_white,
              filled: true,
              errorStyle: GoogleFonts.getFont(
                "IBM Plex Sans Arabic",
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                    color: ColorResources.COLOR_GREY50, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                    color: ColorResources.COLOR_GREY50, width: 0.5),
              ),
              hintText: "155101010",
              hintStyle: GoogleFonts.getFont(
                Strings.fontname,
                fontWeight: FontWeight.normal,
                color: AppColors.grayMedium,
                fontSize: 14,
              )),
          invalidNumberMessage: "Invalid Mobile Number".tr,
          dropdownTextStyle: GoogleFonts.getFont(
            Strings.fontname,
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: widget.textColor,
          ),
          style: GoogleFonts.getFont(
            Strings.fontname,
            fontWeight: FontWeight.w400,
            color: widget.textColor,
            fontSize: 14,
          ),
          onChanged: (phone) {
            widget.onChange(
                phone.completeNumber, phone.number, phone.countryCode);
          },
          keyboardType: TextInputType.number,
          focusNode: widget.myFocusNode,
          initialCountryCode: "EG",
        ),
      ),
    );
  }
}
