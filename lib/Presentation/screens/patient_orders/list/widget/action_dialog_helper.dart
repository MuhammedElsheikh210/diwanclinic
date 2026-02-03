import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../index/index.dart';

class ActionDialogHelper {
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmText,
    required VoidCallback onConfirm,
    Color confirmColor = AppColors.primary,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

        title: AppText(
          text: title,
          textStyle: context.typography.lgBold.copyWith(
            color: confirmColor,
          ),
        ),

        content: AppText(
          text: message,
          textStyle: context.typography.mdMedium.copyWith(
            color: AppColors.textSecondaryParagraph,
          ),
        ),

        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: AppText(
              text: "إلغاء",
              textStyle: context.typography.mdMedium.copyWith(
                color: AppColors.textSecondaryParagraph,
              ),
            ),
          ),

          TextButton(
            onPressed: () {
              Get.back();
              onConfirm();
            },
            child: AppText(
              text: confirmText,
              textStyle: context.typography.mdBold.copyWith(
                color: confirmColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
