import 'package:intl/intl.dart';
import '../../../index/index_main.dart';

class NotificationItem extends StatelessWidget {
  final String title;
  final String? description;

  /// Notification creation date (formatted)
  final String? date;

  /// Appointment date from reservation (dd-MM-yyyy or similar)
  final String? appointmentDate;

  /// Reservation type label (كشف جديد, إعادة, ...)
  final String? reservationType;

  /// Reservation order number
  final int? orderNum;

  /// Notification type key (new_reservation, doctor_late, doctor_arrived, ...)
  final String? notificationType;

  final bool isPatient;
  final bool isUnread;
  final String? imageUrl;
  final bool showActions;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const NotificationItem({
    super.key,
    required this.title,
    this.description,
    this.date,
    this.appointmentDate,
    this.reservationType,
    this.orderNum,
    this.notificationType,
    this.isUnread = false,
    this.imageUrl,
    this.showActions = false,
    this.onAccept,
    this.onReject,
    this.isPatient = false,
  });

  // ── Type config ──────────────────────────────────────────────
  _NotifConfig get _config {
    switch (notificationType) {
      case 'new_reservation':
        return _NotifConfig(
          icon: Icons.calendar_today_rounded,
          iconColor: const Color(0xFF1B8A5A),
          bgColor: const Color(0xFFE6F7EF),
        );
      case 'doctor_late':
        return _NotifConfig(
          icon: Icons.schedule_rounded,
          iconColor: const Color(0xFFE07B00),
          bgColor: const Color(0xFFFFF4E0),
        );
      case 'doctor_arrived':
        return _NotifConfig(
          icon: Icons.check_circle_rounded,
          iconColor: const Color(0xFF1B8A5A),
          bgColor: const Color(0xFFE6F7EF),
        );
      case 'cancelled':
        return _NotifConfig(
          icon: Icons.cancel_rounded,
          iconColor: const Color(0xFFD32F2F),
          bgColor: const Color(0xFFFFEBEE),
        );
      case 'approved':
        return _NotifConfig(
          icon: Icons.check_circle_rounded,
          iconColor: const Color(0xFF1B8A5A),
          bgColor: const Color(0xFFE6F7EF),
        );
      default:
        return _NotifConfig(
          icon: Icons.notifications_rounded,
          iconColor: const Color(0xFF2979FF),
          bgColor: const Color(0xFFE8F0FF),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _config;
    final bool hasReservationMeta =
        appointmentDate != null || reservationType != null || orderNum != null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread
              ? cfg.iconColor.withValues(alpha: 0.4)
              : const Color(0xFFEEEEEE),
          width: isUnread ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Main content ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon bubble
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cfg.bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(cfg.icon, color: cfg.iconColor, size: 22),
                ),

                const SizedBox(width: 12),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: context.typography.mdBold.copyWith(
                                color: const Color(0xFF1A1A2E),
                                height: 1.3,
                              ),
                            ),
                          ),
                          if (isUnread) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                color: cfg.iconColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Description
                      if (description?.trim().isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          description!,
                          style: context.typography.smMedium.copyWith(
                            color: const Color(0xFF6B7280),
                            height: 1.4,
                          ),
                        ),
                      ],

                      // Notification date
                      if (date?.isNotEmpty == true) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: const Color(0xFF9CA3AF),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              date!,
                              style: context.typography.smRegular.copyWith(
                                color: const Color(0xFF9CA3AF),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ─── Reservation meta chips ────────────────────────
          if (hasReservationMeta) ...[
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Row(
                children: [
                  if (appointmentDate != null)
                    _MetaChip(
                      icon: Icons.event_rounded,
                      label: _formatAppointmentDate(appointmentDate!),
                      color: cfg.iconColor,
                    ),

                  if (appointmentDate != null && reservationType != null)
                    _Dot(),

                  if (reservationType != null)
                    _MetaChip(
                      icon: Icons.local_hospital_rounded,
                      label: reservationType!,
                      color: cfg.iconColor,
                    ),

                  if (orderNum != null && (appointmentDate != null || reservationType != null))
                    _Dot(),

                  if (orderNum != null)
                    _MetaChip(
                      icon: Icons.tag_rounded,
                      label: "#$orderNum",
                      color: cfg.iconColor,
                    ),
                ],
              ),
            ),
          ],

          // ─── Transfer image attachment ─────────────────────
          if (imageUrl?.isNotEmpty == true) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: GestureDetector(
                onTap: () => _openImage(context, imageUrl!),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                    color: const Color(0xFFF8F9FA),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Label row
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B8A5A).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.receipt_long_rounded,
                                size: 14,
                                color: Color(0xFF1B8A5A),
                              ),
                            ),
                            const SizedBox(width: 7),
                            const Expanded(
                              child: Text(
                                "إثبات التحويل",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF374151),
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.open_in_full_rounded,
                              size: 13,
                              color: Color(0xFF9CA3AF),
                            ),
                            const SizedBox(width: 2),
                            const Text(
                              "عرض",
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Image preview
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(11),
                          bottomRight: Radius.circular(11),
                        ),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: const Color(0xFFEEEEEE),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF1B8A5A),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFFEEEEEE),
                              child: const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.broken_image_rounded,
                                      color: Color(0xFF9CA3AF),
                                      size: 28,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "تعذّر تحميل الصورة",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          // ─── Action buttons ────────────────────────────────
          if (!isPatient &&
              showActions &&
              isUnread &&
              (onAccept != null || onReject != null)) ...[
            const SizedBox(height: 12),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFEEEEEE)),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Row(
                children: [
                  // Reject
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.close_rounded, size: 16),
                      label: const Text("رفض"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFD32F2F),
                        side: const BorderSide(color: Color(0xFFD32F2F)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Accept
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onAccept,
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text("قبول"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else
            const SizedBox(height: 14),
        ],
      ),
    );
  }

  String _formatAppointmentDate(String raw) {
    try {
      // supports dd-MM-yyyy
      final dt = DateFormat('dd-MM-yyyy').parseStrict(raw);
      return DateFormat('d MMM yyyy', 'ar').format(dt);
    } catch (_) {
      return raw;
    }
  }

  void _openImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(child: Image.network(url)),
        ),
      ),
    );
  }
}

// ── helpers ──────────────────────────────────────────────────

class _NotifConfig {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  const _NotifConfig({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color.withValues(alpha: 0.8)),
        const SizedBox(width: 4),
        Text(
          label,
          style: context.typography.smRegular.copyWith(
            color: const Color(0xFF374151),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: 3,
        height: 3,
        decoration: const BoxDecoration(
          color: Color(0xFFD1D5DB),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
