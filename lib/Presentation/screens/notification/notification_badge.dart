import 'package:flutter/material.dart';

import '../../../index/index_main.dart';

class NotificationBadge extends StatelessWidget {
  final Widget icon;
  final int count;

  const NotificationBadge({super.key, required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,

        if (count > 0)
          Positioned(
            top: -6,
            right: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red, // 🔥 الخلفية الحقيقية
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: BoxConstraints(minWidth: 25.w, minHeight: 25.h),
              child: Center(
                child: Text(
                  count > 9 ? '9+' : count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
