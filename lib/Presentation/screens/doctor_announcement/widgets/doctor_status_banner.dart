import 'package:diwanclinic/index/index_main.dart';

/// A persistent banner shown at the top of any screen when the doctor
/// has an active announcement (arrived / delayed / cancelled / break / resumed).
/// Drop it anywhere — it self-hides when there's no active announcement.
class DoctorStatusBanner extends StatelessWidget {
  const DoctorStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DoctorAnnouncementController>(
      builder: (controller) {
        final announcement = controller.activeAnnouncement;

        if (announcement == null) return const SizedBox.shrink();

        // Hide banner when doctor has arrived — clinic is running normally
        if (announcement.announcementType == DoctorAnnouncementType.arrived) {
          return const SizedBox.shrink();
        }

        final type = announcement.announcementType;
        final color = type.color;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Container(
            key: ValueKey(announcement.key),
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: color.withValues(alpha: 0.30),
                width: 1.2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(type.icon, color: color, size: 20),
                  ),

                  const SizedBox(width: 12),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type.arabicLabel,
                          style: context.typography.mdBold.copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if ((announcement.reason ?? '').isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            announcement.reason!,
                            style: context.typography.smRegular.copyWith(
                              color: color.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                        if ((announcement.estimatedTime ?? '').isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 13,
                                color: color.withValues(alpha: 0.75),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'وقت الوصول المتوقع: ${announcement.estimatedTime}',
                                style: context.typography.xsMedium.copyWith(
                                  color: color.withValues(alpha: 0.75),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Create button (only for doctor/assistant)
                  if (controller.canCreate) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _showCreateSheet(context, controller),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCreateSheet(
    BuildContext context,
    DoctorAnnouncementController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateAnnouncementBottomSheet(),
    );
  }
}

/// Compact FAB-style button to trigger announcement creation.
/// Shown only to doctor/assistant.
class CreateAnnouncementFab extends StatelessWidget {
  const CreateAnnouncementFab({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DoctorAnnouncementController>(
      builder: (controller) {
        if (!controller.canCreate) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const CreateAnnouncementBottomSheet(),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.campaign_outlined, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  'إعلان',
                  style: context.typography.smMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
