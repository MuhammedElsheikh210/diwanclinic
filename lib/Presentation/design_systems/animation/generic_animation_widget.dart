import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../design_constants/colors/app_colors.dart';

class GenericAnimationWidget extends StatelessWidget {
  final String animation_file_name;

  const GenericAnimationWidget({super.key, required this.animation_file_name});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      animation_file_name,
      repeat: true,
      // تعيد التشغيل
      reverse: false,
      // ممكن تخليها true لو عايزها بالعكس
      animate: true, // تتحرك تلقائيًا
    );
  }
}
