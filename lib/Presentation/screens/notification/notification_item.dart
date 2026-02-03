import '../../../index/index_main.dart';

class NotificationItem extends StatelessWidget {
  final String title;
  final String? description;
  final String? date;

  /// 👤 User type
  final bool isPatient;

  /// 🔔 State
  final bool isUnread;

  /// 🖼️ Optional image (transfer / attachment)
  final String? imageUrl;

  /// 🔥 Actions (Assistant / Doctor only)
  final bool showActions;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const NotificationItem({
    super.key,
    required this.title,
    this.description,
    this.date,
    this.isUnread = false,
    this.imageUrl,
    this.showActions = false,
    this.onAccept,
    this.onReject,
    this.isPatient = false, // 👈 NEW
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        // 🎨 Background
        color: isUnread
            ? (isPatient
            ? AppColors.white
            : AppColors.tag_icon_warning.withValues(alpha: 0.2))
            : AppColors.white,

        borderRadius: BorderRadius.circular(14.r),

        // 🧱 Border
        border: Border.all(
          color: isUnread
              ? (isPatient
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.primary.withValues(alpha: 0.7))
              : AppColors.borderNeutralPrimary,
          width: 1.2,
        ),

        // 🌫 Shadow
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ───────────── Header ─────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isUnread)
                Container(
                  width: 8,
                  height: 8,
                  margin: EdgeInsets.only(top: 6.h),
                  decoration: BoxDecoration(
                    color: isPatient
                        ? AppColors.primary
                        : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),

              SizedBox(width: isUnread ? 8.w : 0),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.typography.mdBold,
                    ),

                    if (description?.trim().isNotEmpty == true) ...[
                      SizedBox(height: 4.h),
                      Text(
                        description!,
                        style: context.typography.mdRegular.copyWith(
                          color: AppColors.textSecondaryParagraph,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              if (date?.isNotEmpty == true)
                Text(
                  date!,
                  style: context.typography.smRegular.copyWith(
                    color: AppColors.textSecondaryParagraph,
                  ),
                ),
            ],
          ),

          // ───────────── Image (if exists) ─────────────
          if (imageUrl?.isNotEmpty == true) ...[
            SizedBox(height: 10.h),
            GestureDetector(
              onTap: () => _openImage(context, imageUrl!),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.borderNeutralPrimary.withValues(
                        alpha: 0.2,
                      ),
                      child: const Icon(Icons.broken_image),
                    ),
                  ),
                ),
              ),
            ),
          ],

          // ───────────── Actions (Assistant only) ─────────────
          if (!isPatient &&
              showActions &&
              isUnread &&
              (onAccept != null || onReject != null)) ...[
            SizedBox(height: 12.h),
            const Divider(),
            SizedBox(height: 10.h),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.errorForeground,
                      side: const BorderSide(
                        color: AppColors.errorBackground,
                      ),
                    ),
                    child: const Text("رفض"),
                  ),
                ),

                SizedBox(width: 10.w),

                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text(
                      "قبول",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ───────────── Full Screen Image ─────────────
  void _openImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: Image.network(url),
          ),
        ),
      ),
    );
  }
}
