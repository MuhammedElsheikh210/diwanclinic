
import '../../index/index_main.dart';

class CustomButtonWidget extends StatelessWidget {
  final double width;
  final double height;
  final double borderradius;
  final double? borderwidth;
  final Color? borderradius_color;
  final Widget text;
  final Color backgroundcolor;
  final Function? onpress;

  const CustomButtonWidget(
      {Key? key,
      required this.width,
      required this.height,
      required this.onpress,
      required this.borderradius,
      required this.text,
      required this.backgroundcolor,
      this.borderradius_color,
      this.borderwidth})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        onpress!();
      },
      style: ElevatedButton.styleFrom(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderradius),
          ),
          backgroundColor: backgroundcolor,
          fixedSize: Size(width, height)),
      child: text,
    );
  }
}
