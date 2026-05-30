import '../../../../index/index_main.dart';

class AdminDoctorExpandableCard extends StatelessWidget {
  final LocalUser doctor;
  final List<LocalUser> assistants;
  final AdminUsersViewModel controller;

  const AdminDoctorExpandableCard({
    super.key,
    required this.doctor,
    required this.assistants,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isExpanded = controller.isDoctorExpanded(doctor.uid ?? '');

    return Column(
      children: [
        // ── Doctor row ──────────────────────────────────────────
        GestureDetector(
          onTap: assistants.isNotEmpty
              ? () => controller.toggleDoctor(doctor.uid ?? '')
              : null,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 14.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.borderNeutralPrimary, width: 1),
              borderRadius: isExpanded
                  ? BorderRadius.vertical(top: Radius.circular(12.r))
                  : BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                _avatar(doctor),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name ?? '—',
                        style: context.typography.mdBold.copyWith(
                          color: AppColors.textDisplay,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if ((doctor.phone ?? '').isNotEmpty) ...[
                        SizedBox(height: 3.h),
                        Text(
                          doctor.phone!,
                          style: context.typography.smRegular.copyWith(
                            color: AppColors.textSecondaryParagraph,
                          ),
                        ),
                      ],
                      SizedBox(height: 5.h),
                      Row(
                        children: [
                          _doctorBadge(context),
                          if (assistants.isNotEmpty) ...[
                            SizedBox(width: 6.w),
                            _assistantCountBadge(context),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Delete doctor button
                IconButton(
                  onPressed: () => _confirmDelete(context, doctor, 'طبيب'),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.errorForeground,
                  ),
                  iconSize: 22,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                if (assistants.isNotEmpty) ...[
                  SizedBox(width: 8.w),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // ── Assistants expanded section ──────────────────────────
        if (isExpanded && assistants.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: AppColors.background_neutral_25,
              border: Border(
                left: BorderSide(color: AppColors.borderNeutralPrimary, width: 1),
                right: BorderSide(color: AppColors.borderNeutralPrimary, width: 1),
                bottom: BorderSide(color: AppColors.borderNeutralPrimary, width: 1),
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12.r)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  child: Row(
                    children: [
                      Icon(Icons.people_alt_outlined, size: 14, color: AppColors.blueForeground),
                      SizedBox(width: 6.w),
                      Text(
                        'المساعدون',
                        style: context.typography.smMedium.copyWith(
                          color: AppColors.blueForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                ...assistants.map(
                  (assistant) => Padding(
                    padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 8.h),
                    child: _AssistantRow(
                      assistant: assistant,
                      controller: controller,
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
              ],
            ),
          ),
      ],
    );
  }

  Widget _avatar(LocalUser user) {
    final initial = (user.name ?? '?').isNotEmpty
        ? user.name![0].toUpperCase()
        : '?';

    if (user.hasImage) {
      return CircleAvatar(
        radius: 22.r,
        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
        backgroundImage: NetworkImage(user.profileImage!),
      );
    }

    return CircleAvatar(
      radius: 22.r,
      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
      child: Text(
        initial,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 16.sp,
        ),
      ),
    );
  }

  Widget _doctorBadge(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'طبيب',
        style: context.typography.xsRegular.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _assistantCountBadge(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.blueForeground.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${assistants.length} مساعد',
        style: context.typography.xsRegular.copyWith(
          color: AppColors.blueForeground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, LocalUser user, String role) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => ConfirmBottomSheet(
        title: 'حذف $role',
        message: 'هل أنت متأكد من حذف "${user.name ?? ''}"؟\nلن تتمكن من استعادة البيانات بعد الحذف.',
        confirmText: 'حذف',
        cancelText: 'إلغاء',
        onConfirm: () => controller.deleteUser(user),
      ),
    );
  }
}

// ── Assistant row inside expanded doctor ──────────────────────────────────────

class _AssistantRow extends StatelessWidget {
  final LocalUser assistant;
  final AdminUsersViewModel controller;

  const _AssistantRow({required this.assistant, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.borderNeutralPrimary, width: 0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 17.r,
            backgroundColor: AppColors.blueForeground.withValues(alpha: 0.12),
            child: Text(
              (assistant.name ?? '?').isNotEmpty
                  ? assistant.name![0].toUpperCase()
                  : '?',
              style: TextStyle(
                color: AppColors.blueForeground,
                fontWeight: FontWeight.bold,
                fontSize: 13.sp,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assistant.name ?? '—',
                  style: context.typography.smMedium.copyWith(
                    color: AppColors.textDisplay,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if ((assistant.phone ?? '').isNotEmpty)
                  Text(
                    assistant.phone!,
                    style: context.typography.xsRegular.copyWith(
                      color: AppColors.textSecondaryParagraph,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppColors.blueForeground.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'مساعد',
              style: context.typography.xsRegular.copyWith(
                color: AppColors.blueForeground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 6.w),
          IconButton(
            onPressed: () => _confirmDelete(context),
            icon: const Icon(Icons.delete_outline, color: AppColors.errorForeground),
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => ConfirmBottomSheet(
        title: 'حذف مساعد',
        message: 'هل أنت متأكد من حذف "${assistant.name ?? ''}"؟\nلن تتمكن من استعادة البيانات بعد الحذف.',
        confirmText: 'حذف',
        cancelText: 'إلغاء',
        onConfirm: () => controller.deleteUser(assistant),
      ),
    );
  }
}
