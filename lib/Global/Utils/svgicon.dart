import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Svgicon extends StatelessWidget {
  final String icon;
  final Color? color;
  final double? height;
  final double? width;

  const Svgicon(
      {Key? key, required this.icon, this.color, this.height, this.width})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      icon,
      color: color,
      height: height,
      width: width,
    );
  }
}
